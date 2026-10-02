import requests
from pprint import pprint
import argparse

parser = argparse.ArgumentParser(description='Sample inference for imajev')
parser.add_argument("--base-url", type=str, help="Base URL of the SystemOne API", default="http://localhost:8765")
args = parser.parse_args()

base_url = args.base_url
data = {
    "state": {
        "ticket": {
            "id": "TKT-48812",
            "from": "dana.okafor@northwind-labs.example",
            "received": "2026-09-21T08:14:00Z",
            "subject": "Charged twice for the September seats - third email",
            "body": "We were billed 480 USD twice on 3 September for the same 12 seats. I have now written three times and the only reply was an automated one. Our finance close is on Wednesday and I need the duplicate reversed before then. Nothing is broken in the product itself.",
            "plan": "Team (12 seats)",
            "prior_tickets_90d": 2,
        }
    },
    "questions": {
        "department": {
            "type": "choice",
            "instructions": "Which department should own this ticket?",
            "criteria": {
                "billing": "payments, invoices, refunds and subscription charges",
                "technical_support": "the product is broken, erroring or unavailable",
                "sales": "new seats, upgrades, quotes and renewals",
                "account_management": "ownership, access and contract administration",
            },
        },
        "urgent": {
            "type": "noul",
            "instructions": "This ticket needs a reply today.",
            "criteria": {
                "true": "money is at stake or the customer has a dated deadline within days",
                "false": "it can wait for the normal queue",
            },
        },
        "frustration": {
            "type": "score",
            "instructions": "How frustrated does the customer sound?",
            "criteria": [
                "calm and matter-of-fact",
                "impatient: chasing a reply or repeating themselves",
                "angry: threatening to escalate, churn or dispute the charge",
            ],
        },
    },
}

route = base_url + "/v1/systemone"
headers = {"Content-Type": "application/json"}
pprint(data, sort_dicts=False)
response = requests.post(route, headers=headers, json=data)
response.raise_for_status()

pprint(response.json(), sort_dicts=False)
