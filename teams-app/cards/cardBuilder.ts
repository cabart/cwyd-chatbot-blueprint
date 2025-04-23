import { Attachment, CardFactory } from "botbuilder";
import { Citation, CardType } from "../model";
import { markdownToAdaptiveCards } from "./formatting";
import config from "../config";


export function actionBuilder(citation: Citation, docId: number): any {

    const urlParts = citation.url.split("]");
    let url = config.blobBaseUrl.concat("/", urlParts[urlParts.length - 1].replaceAll("(", "").replaceAll(")", ""));
    let title = citation.title.replaceAll("/documents/", "");
    let content = citation.content.replaceAll(citation.title, "").replaceAll("url", "");
    // remove html tags if there are any -> should not happen, we assume to have markdown input
    content = content.replaceAll(/(<([^>]+)>)/ig, "\n").replaceAll("<>", "");
    // header formatting from markdown to subset of teams supported markdown # heading -> **heading**
    const headingRegex = /#{1,6} (.*?)(\r?\n|$)/g;
    content = content.replace(headingRegex, '\n\n**$1**');
    // formatting of list items
    const itemRegex = /• (.*?)(\r?\n|$)/g;
    content = content.replaceAll(itemRegex, (match, itemContent) => {
        if (itemContent.includes(':\n')) {
            return `\n* ${itemContent.replace(':\n', ': ')}\n`;
        } else {
            return `\n* ${itemContent}\n`;
        }
    });

    // show table
    const extractedContent = markdownToAdaptiveCards(content);

    let citationCardAction = {
        title: `[${docId}] ${title}`,
        type: CardType.ShowCard,
        card: {
            type: CardType.AdaptiveCard,
            body: [
                {
                    type: CardType.TextBlock,
                    text: `Reference - Part ${parseInt(citation.chunk_id) + 1}`,
                    wrap: true,
                    size: "small",
                },
                {
                    type: CardType.TextBlock,
                    text: title,
                    wrap: true,
                    weight: "Bolder",
                    size: "Large",
                },
                ...extractedContent  // add individual entries here
            ],
            actions: [
                {
                    type: CardType.OpenUrl,
                    title: "Go to the source",
                    url: url,
                }
            ]
        }
    };

    return citationCardAction;
}
export function cardBodyBuilder(citations: any[], assistantAnswer: string): any {
    let answerCard = {
        "$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
        "version": "1.6",
        type: CardType.AdaptiveCard,
        body: [
            {
                type: CardType.TextBlock,
                text: assistantAnswer,
                wrap: true

            }, {
                type: 'ActionSet',
                actions: []
            }
        ],
        actions: [],
        msteams: {
            width: "Full"
        }
    };
    if (citations.length <= 6) {
        answerCard["actions"] = citations;
    } else {
        const chunkSize = 5;
        for (let i = 0; i < citations.length; i += chunkSize) {
            const chunk = citations.slice(i, i + chunkSize);
            answerCard["body"].push({
                type: 'ActionSet',
                actions: chunk
            });
        }
    }

    return answerCard;
}
export function cwydResponseBuilder(citations: Citation[], assistantAnswer: string): Attachment {
    let citationActions: any[] = [];
    let refCount = 1;
    citations.map((citation: Citation) => {
        const refStr = `[doc${refCount}]`;
        if (assistantAnswer.includes(refStr)) {
            assistantAnswer = assistantAnswer.replaceAll(refStr, `[${refCount}]`);
            citationActions.push(actionBuilder(citation, refCount));
        }
        refCount++;
    });
    let answerCard = CardFactory.adaptiveCard(cardBodyBuilder(citationActions, assistantAnswer));
    return answerCard;
}