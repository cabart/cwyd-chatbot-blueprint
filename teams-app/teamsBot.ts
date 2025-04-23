import { OAuthPrompt, DialogSet, DialogTurnStatus, PromptValidatorContext } from 'botbuilder-dialogs';
import { ManagedIdentityCredential } from '@azure/identity';
import {
  TeamsActivityHandler,
  TurnContext,
  ActivityTypes,
  MessageFactory,
  TokenResponse,
  Activity
} from "botbuilder";
import jwt, { JwtPayload, Algorithm } from 'jsonwebtoken';
import {
  ChatMessage,
  ChatResponse,
  ToolMessageContent,
  Citation,
} from "./model";
import config from "./config";
import { cwydResponseBuilder } from "./cards/cardBuilder";


const EMPTY_RESPONSE = "Sorry, I do not have an answer. Please try again.";


export class TeamsBot extends TeamsActivityHandler {
  private dialogs: any;
  private dialogState: any;
  private conversationState: any;

  constructor(conversationState) {
    super();
    this.conversationState = conversationState;
    this.dialogState = this.conversationState.createProperty('DialogState');
    this.dialogs = new DialogSet(this.dialogState);
    // Dialog responsible for SSO and caches the token internally. We use custom verification.
    this.dialogs.add(new OAuthPrompt('OAuthPrompt', {
      connectionName: 'OAuthSettings', // your connection name here
      text: 'Please Sign In',
      title: 'Sign In',
      timeout: 30000,
      showSignInLink: true
    }));

    this.onMessage(async (context, next) => {
      // Create a dialog context
      const dc = await this.dialogs.createContext(context);

      // Token handling for SSO
      let token: string;
      // Continue the dialog
      const results = await dc.continueDialog();
      // If no dialog is active, then we will proceed with the OAuthPrompt to get the token.
      if (results.status === 'empty') {  // run on each message
        const response = await dc.beginDialog('OAuthPrompt');
        console.log("token response:", response);
        if (response.result && response.result.token) {
          token = response.result.token;
        }
      } else if (results.status === DialogTurnStatus.complete) {  // after user consent
        const tokenResponse = results.result;
        // Log the token response
        if (tokenResponse) {
          await context.sendActivity(`You are now logged in.`);
          if (tokenResponse.token) {
            token = tokenResponse.token;
          }
        } else {
          console.error('Token response is undefined. Unable to log in.');
          await context.sendActivity('We couldn\'t log you in. Please try again later.');
        }
      }

      const tokenResult = await dc.beginDialog('OAuthPrompt');
      if(tokenResult.result && tokenResult.result.token){
        token = tokenResult.result.token;
      }
      // Authorize access to question answering
      if (token) {
        const valid = await this.verifyToken(token, config.tenantId, config.expectedAudience);
        if (valid) {
          await this.answerQuestion(context);
        }
      }
      // Proceed to the next middleware
      await next();
      await this.conversationState.saveChanges(context);
    });
  }

  async verifyToken(token: string, tenantId: string, expectedAudience: string) {
    const tokenWithHeader = jwt.decode(token, { complete: true }) as JwtPayload;
    if (!tokenWithHeader) {
      return false;
    }
    const decodedToken = tokenWithHeader.payload;
    const expectedIssuer = `https://login.microsoftonline.com/${tenantId}/v2.0`;
    if (decodedToken.aud !== expectedAudience) {
      console.error('Invalid audience: ', decodedToken.aud, ' should be:', expectedAudience);
    }

    if(decodedToken.iss !== expectedIssuer){
      console.error('Invalid issuer: ', decodedToken.iss, ' should be:', expectedIssuer);
    }

    // Verify token signature
    const jwksUri = `https://login.microsoftonline.com/${tenantId}/discovery/v2.0/keys`; // Adjust as needed
    const { keys } = await fetch(jwksUri).then(res => res.json());

    if (!keys) {
      console.error("Could not retrieve keys for verifying the token signature.");
      return false;
    }

    const signingKey = keys.find(key => {
      return key.kid === tokenWithHeader.header.kid
    });

    if (!signingKey) {
      console.error('Signing key not found from list of keys.');
      return false;
    }

    const options = {
      algorithms: ['RS256'] as Algorithm[],
      issuer: expectedIssuer,
      audience: expectedAudience,
      ignoreExpiration: false
    };

    // Format the signature such that it is in the expected format.
    const pem = `-----BEGIN CERTIFICATE-----\n${signingKey.x5c[0]}\n-----END CERTIFICATE-----`;

    try {
      jwt.verify(token, pem, options);
      return true;
    } catch (error) {
      console.error('Token verification failed:', error);
      return false;
    }
  }

  async answerQuestion(context: TurnContext) {
    let newActivity: Partial<Activity>;
    let assistantAnswer = "";
    let activityUpdated = true;
    try {
      const removedMentionText = TurnContext.removeRecipientMention(
        context.activity
      );
      const txt = removedMentionText.toLowerCase().replace(/\n|\r/g, "").trim();

      const reply = await context.sendActivity("Searching ...");

      // Create a new activity with the user's message as a reply.
      const answers: ChatMessage[] = [];
      const userMessage: ChatMessage = {
        role: "user",
        content: txt,
      };

      // Call the Azure Function to get the response from Azure OpenAI on your Data
      // authenticate to backend service if required
      let headers = {};
      if (!config.azureFunctionUrl.includes("http://localhost")) {
        const credential = new ManagedIdentityCredential();
        const token = await credential.getToken(`api://${config.backendAppId}/.default`);
        console.log("token: ", token);
        headers = {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${token.token}`,
        }
      } else {
        headers = {
          "Content-Type": "application/json"
        }
      }

      const request = {
        method: "POST",
        headers: headers,
        body: JSON.stringify({
          should_stream: false,
          messages: [userMessage],
          conversation_id: "",
        }),
      }

      let result = {} as ChatResponse;
      try {
        const response = await fetch(config.azureFunctionUrl, request);
        // Parse the response
        if (response?.body) {
          const reader = response.body.getReader();
          let runningText = "";
          while (true) {
            const { done, value } = await reader.read();
            if (done) break;

            var text = new TextDecoder("utf-8").decode(value);
            const objects = text.split("\n").filter(obj => obj != "");

            objects.forEach((obj) => {
              try {
                runningText += obj;
                result = JSON.parse(runningText);
                if (result.error) {
                  answers.push(userMessage, {
                    role: "error",
                    content:
                      "ERROR: " + result.error + " | " + EMPTY_RESPONSE,
                  });
                } else {
                  answers.push(userMessage, ...result.choices[0].messages);
                }
                runningText = "";
              } catch (e) {
                const errorMessage: ChatMessage = {
                  role: "error",
                  content: e.message,
                };
                answers.push(errorMessage);
              }
            });
          }
        }
      } catch (e) {
        console.error(e);
        const errorMessage: ChatMessage = {
          role: "error",
          content: e.message,
        };
        answers.push(errorMessage);
      }

      // Parse the citations from the tool message
      const parseCitationFromMessage = (message: ChatMessage) => {
        if (message.role === "tool") {
          try {
            const toolMessage = JSON.parse(
              message.content
            ) as ToolMessageContent;
            return toolMessage.citations;
          } catch {
            return [];
          }
        }
        return [];
      };

      // Generate the response for the user
      answers.map((answer, index) => {
        if (answer.role === "assistant") {
          assistantAnswer = answer.content;
          if (assistantAnswer.startsWith("[doc")) {
            assistantAnswer = EMPTY_RESPONSE;
            newActivity = MessageFactory.text(assistantAnswer);
          } else {
            const citations = parseCitationFromMessage(answers[index - 1]) as Citation[];
            if (citations.length === 0) {
              newActivity = MessageFactory.text(assistantAnswer);
              newActivity.id = reply.id;
            } else {
              newActivity = MessageFactory.attachment(cwydResponseBuilder(citations, assistantAnswer));
              activityUpdated = false;
            }
          }
        } else if (answer.role === "error") {
          newActivity = MessageFactory.text(
            "Sorry, an error occurred. Try waiting a few minutes. If the issue persists, contact your system administrator. Error: " +
            answer.content
          );
          newActivity.id = reply.id;
        }

      });

      if (activityUpdated) {
        await context.updateActivity(newActivity);
      } else {
        try {
          await context.deleteActivity(reply.id);
        } catch (error) {
          console.log('Error in deleting message', error);
        }
        await context.sendActivity(newActivity);
      }

    } catch (error) {
      console.log('Error in onMessage:', error);
    } finally {
    }
  }

}