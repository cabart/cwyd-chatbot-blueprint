import * as restify from 'restify';
import { CloudAdapter, ConversationState, MemoryStorage, UserState, ConfigurationBotFrameworkAuthentication, TeamsSSOTokenExchangeMiddleware, ConfigurationServiceClientCredentialFactory } from 'botbuilder';
import { TeamsBot } from './teamsBot';
import config from './config';

// Create adapter.
// See https://aka.ms/about-bot-adapter to learn more about adapters.
const credentialsFactory = new ConfigurationServiceClientCredentialFactory({
  MicrosoftAppId: config.botId,
  MicrosoftAppPassword: config.botPassword,
  MicrosoftAppType: "MultiTenant",
  MicrosoftAppTenantId: "common"
});

const botFrameworkAuthentication = new ConfigurationBotFrameworkAuthentication(
  {},
  credentialsFactory
);

const adapter = new CloudAdapter(botFrameworkAuthentication);
const memoryStorage = new MemoryStorage();
const tokenExchangeMiddleware = new TeamsSSOTokenExchangeMiddleware(memoryStorage, config.connectionName);
adapter.use(tokenExchangeMiddleware);
const conversationState = new ConversationState(memoryStorage);

const bot = new TeamsBot(conversationState);

adapter.onTurnError = async (context, error) => {
  console.error(`\n [onTurnError] unhandled error: ${error}`);
  console.error('Error stack: ', error.stack);
  console.error('Context at time of error: ', JSON.stringify(context, null, 2));
  console.error('conversationState: ', conversationState);
  await context.sendActivity('The bot encountered an error or bug.');
  await context.sendActivity('To continue to run this bot, please fix the bot source code.');
  await conversationState.delete(context);
};

const server = restify.createServer();
server.use(restify.plugins.bodyParser());

server.listen(process.env.port || process.env.PORT || 3978, function () {
  console.log(`\n${server.name} listening to ${server.url}`);
});

server.post('/api/messages', async (req, res) => {
  console.log('Received a message');  // Add this line
  await adapter.process(req, res, async (context) => bot.run(context));
});
