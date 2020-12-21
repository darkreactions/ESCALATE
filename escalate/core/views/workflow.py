from core.views.crud_views import LoginRequired
from django.shortcuts import render
from django.views import View

http_components = """[{
              "type": "ReceiveHttpRequest",
              "displayName": "Receive HTTP Request",
              "description": "Receive an incoming HTTP request.",
              "runtimeDescription": "x => !!x.state.path ? `Handle <strong>${ x.state.method } ${ x.state.path }</strong>.` : x.definition.description",
              "category": "HTTP",
              "outcomes": ["Done"],
              "properties": [
                {
                  "name": "path",
                  "type": "text",
                  "label": "Path",
                  "hint": "The relative path that triggers this activity.",
                  "options": {}
                },
                {
                  "name": "method",
                  "type": "select",
                  "label": "Method",
                  "hint": "The HTTP method that triggers this activity.",
                  "options": {
                    "items": [
                      "GET",
                      "POST",
                      "PUT",
                      "DELETE",
                      "PATCH",
                      "OPTIONS",
                      "POOP"
                    ]
                  }
                },
                {
                  "name": "readContent",
                  "type": "boolean",
                  "label": "Read Content",
                  "hint": "A value indicating whether the HTTP request content body should be read and stored as part of the HTTP request model. The stored format depends on the content-type header.",
                  "options": {}
                },
                {
                  "name": "name",
                  "type": "text",
                  "label": "Name",
                  "hint": "Optionally provide a name for this activity. You can reference named activities from expressions.",
                  "options": {}
                },
                {
                  "name": "title",
                  "type": "text",
                  "label": "Title",
                  "hint": "Optionally provide a custom title for this activity.",
                  "options": {}
                },
                {
                  "name": "description",
                  "type": "text",
                  "label": "Description",
                  "hint": "Optionally provide a custom description for this activity.",
                  "options": {}
                }
              ]
            }]"""

http_workflow = """
                                    {
                    "activities": [
                        {
                            "id": "2c8d9868-a0ce-416f-b07f-915186b93a54",
                            "top": 159,
                            "left": 673,
                            "type": "ReceiveHttpRequest",
                            "state": {}
                        },
                        {
                            "id": "2cfafd9c-1b76-4497-8111-fe79edd30ef5",
                            "top": 150,
                            "left": 150,
                            "type": "ReceiveHttpRequest",
                            "state": {}
                        }
                    ],
                    "connections": [
                        {
                            "sourceActivityId": "2cfafd9c-1b76-4497-8111-fe79edd30ef5",
                            "destinationActivityId": "2c8d9868-a0ce-416f-b07f-915186b93a54",
                            "outcome": ""
                        }
                    ]
                }
                """

mojito_components = """[{
                    "type": "mint_to_shaker",
                    "displayName": "Mint Leaf -> Cocktail Shaker",
                    "description": "transfer_discrete",
                    "runtimeDescription": "x => !!x.state.count ? `${ x.state.count } Leaves` : x.definition.description ",
                    "category": "template",
                    "outcomes": ["Done"],
                    "icon": "fas fa-feather-alt",
                    "properties": [
                        {
                        "name": "count",
                        "type": "text",
                        "label": "Count",
                        "hint": "Number of mint leaves",
                        "options": {}
                        }]
                },
                {
                    "type": "syrup_to_shaker",
                    "displayName": "Simple Syrup -> Cocktail Shaker",
                    "runtimeDescription": "x => !!x.state.volume ? `${ x.state.volume } fl oz` : x.definition.description ",
                    "description": "dispense",
                    "category": "template",
                    "outcomes": ["Done"],
                    "properties": [
                        {
                        "name": "volume",
                        "type": "text",
                        "label": "Volume",
                        "hint": "Volume in floz",
                        "options": {}
                        }]
                },
                {
                    "type": "muddle",
                    "displayName": "Cocktail Shaker -> Cocktail Shaker",
                    "runtimeDescription": "x => !!x.state.force ? `${ x.state.force }` : x.definition.description ",
                    "description": "muddle",
                    "category": "template",
                    "outcomes": ["Done"],
                    "properties": [
                        {
                        "name": "force",
                        "type": "text",
                        "label": "Force",
                        "hint": "",
                        "options": {}
                        }]
                },
                {
                    "type": "rum_to_shaker",
                    "displayName": "White Rum -> Cocktail Shaker",
                    "runtimeDescription": "x => !!x.state.volume ? `${ x.state.volume } fl oz` : x.definition.description ",
                    "description": "dispense",
                    "category": "template",
                    "outcomes": ["Done"],
                    "properties": [
                        {
                            "name": "volume",
                            "type": "text",
                            "label": "Volume",
                            "hint": "Volume in floz",
                            "options": {}
                            }]
                },
                {
                    "type": "lime_juice_to_shaker",
                    "displayName": "Lime Juice -> Cocktail Shaker",
                    "runtimeDescription": "x => !!x.state.volume ? `${ x.state.volume } fl oz` : x.definition.description ",
                    "description": "dispense",
                    "category": "template",
                    "outcomes": ["Done"],
                    "properties": [
                        {
                            "name": "volume",
                            "type": "text",
                            "label": "Volume",
                            "hint": "Volume in floz",
                            "options": {}
                            }]
                },
                {
                    "type": "shake",
                    "displayName": "Cocktail Shaker -> Cocktail Shaker",
                    "runtimeDescription": "x => !!x.state.duration_qualitative ? `${ x.state.duration_qualitative }` : x.definition.description ",
                    "description": "shake",
                    "category": "template",
                    "outcomes": ["Done"],
                    "properties": [
                        {
                            "name": "duration_qualitative",
                            "type": "text",
                            "label": "Duration (Qualitative)",
                            "hint": "Time taken",
                            "options": {}
                            }]
                },
                {
                    "type": "ice_to_glass",
                    "displayName": "Ice Cube -> Highball Glass",
                    "description": "transfer_discrete",
                    "runtimeDescription": "x => !!x.state.count ? `${ x.state.count } Leaves` : x.definition.description ",
                    "category": "template",
                    "icon": "fas fa-dice-d6",
                    "outcomes": ["Done", "Fail"],
                    "properties": [
                        {
                            "name": "count",
                            "type": "text",
                            "label": "Count",
                            "hint": "Number of Ice Cubes",
                            "options": {}
                            }]
                },
                {
                    "type": "mojito_to_glass",
                    "displayName": "Cocktail Shaker -> Highball Glass",
                    "description": "strain",
                    "category": "template",
                    "icon": "fas fa-cocktail",
                    "outcomes": ["Done"],
                    "properties": []
                },
                {
                    "type": "Outcome",
                    "displayName": "sample mojito taste",
                    "runtimeDescription": "x => !!x.state.measure ? `${ x.state.measure }` : x.definition.description ",
                    "description": "measure",
                    "category": "template",
                    "icon": "fas fa-database",
                    "outcomes": [],
                    "properties": [
                        {
                            "name": "measure",
                            "type": "text",
                            "label": "Taste measure",
                            "hint": "Qualitative taste",
                            "options": {}
                            }]
                }
    
                ]   
              """


mojito_workflow = """
{
    "activities": [
        {
            "id": "4b16c09b-5f1b-41db-9da6-ddfa679b4364",
            "top": 12,
            "left": 23,
            "type": "mint_to_shaker",
            "faulted": true,
            "message":{"title":"Faulted","content":"This didnt work."},
            "state": {
                "count": "3"
            }
        },
        {
            "id": "de652d59-4d4c-4352-84cb-fcedfe4df422",
            "top": 14,
            "left": 403,
            "type": "syrup_to_shaker",
            "state": {
                "volume": "0.5"
            }
        },
        {
            "id": "4e363a0d-3a50-44d1-8ae2-a156be672278",
            "top": 13,
            "left": 764,
            "type": "muddle",
            "state": {
                "force": "lightly"
            }
        },
        {
            "id": "23a1f0fe-16c9-4f16-a3ad-249b32e8bb1d",
            "top": 211,
            "left": 808,
            "type": "rum_to_shaker",
            "state": {
                "volume": "2"
            }
        },
        {
            "id": "b23e39cd-485b-413d-91fe-0ad4663be2dd",
            "top": 210,
            "left": 458,
            "type": "lime_juice_to_shaker",
            "state": {
                "volume": "0.75"
            }
        },
        {
            "id": "6155ef62-e679-44bf-a6f2-8e4b44e335c5",
            "top": 213,
            "left": 56,
            "type": "shake",
            "state": {
                "duration_qualitative": "briefly"
            }
        },
        {
            "id": "5249f4cc-7aa2-4fda-a7cc-ae6926b177cc",
            "top": 421,
            "left": 55,
            "type": "ice_to_glass",
            "state": {
                "count": "5"
            }
        },
        {
            "id": "7fa1a837-6e7e-49ea-9f32-125e556ea361",
            "top": 421,
            "left": 460,
            "type": "mojito_to_glass",
            "state": {}
        },
        {
            "id": "7fa1a837-6e7e-49ea-9f32-125e556ea362",
            "top": 421,
            "left": 860,
            "type": "Outcome",
            "state": {}
        }
    ],
    "connections": [
        {
            "sourceActivityId": "4b16c09b-5f1b-41db-9da6-ddfa679b4364",
            "destinationActivityId": "de652d59-4d4c-4352-84cb-fcedfe4df422",
            "outcome": "Done"
        },
        {
            "sourceActivityId": "de652d59-4d4c-4352-84cb-fcedfe4df422",
            "destinationActivityId": "4e363a0d-3a50-44d1-8ae2-a156be672278",
            "outcome": "Done"
        },
        {
            "sourceActivityId": "4e363a0d-3a50-44d1-8ae2-a156be672278",
            "destinationActivityId": "23a1f0fe-16c9-4f16-a3ad-249b32e8bb1d",
            "outcome": "Done"
        },
        {
            "sourceActivityId": "23a1f0fe-16c9-4f16-a3ad-249b32e8bb1d",
            "destinationActivityId": "b23e39cd-485b-413d-91fe-0ad4663be2dd",
            "outcome": "Done"
        },
        {
            "sourceActivityId": "b23e39cd-485b-413d-91fe-0ad4663be2dd",
            "destinationActivityId": "6155ef62-e679-44bf-a6f2-8e4b44e335c5",
            "outcome": "Done"
        },
        {
            "sourceActivityId": "6155ef62-e679-44bf-a6f2-8e4b44e335c5",
            "destinationActivityId": "5249f4cc-7aa2-4fda-a7cc-ae6926b177cc",
            "outcome": "Done"
        },
        {
            "sourceActivityId": "5249f4cc-7aa2-4fda-a7cc-ae6926b177cc",
            "destinationActivityId": "7fa1a837-6e7e-49ea-9f32-125e556ea361",
            "outcome": "Done"
        },
        {
            "sourceActivityId": "7fa1a837-6e7e-49ea-9f32-125e556ea361",
            "destinationActivityId": "7fa1a837-6e7e-49ea-9f32-125e556ea362",
            "outcome": "Done"
        }
    ]
}

"""


class WorkflowView(LoginRequired, View):
    template_name = 'core/workflow.html'

    # @method_decorator(login_required)
    def get(self, request, *args, **kwargs):
        components = mojito_components

        #workflow = http_workflow
        workflow = mojito_workflow

        context = {'components': components, 'workflow': workflow}

        return render(request, self.template_name, context=context)
