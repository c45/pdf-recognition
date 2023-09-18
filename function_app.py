from azure.core.credentials import AzureKeyCredential
from azure.ai.formrecognizer import DocumentAnalysisClient
from dotenv import load_dotenv
import azure.functions as func
import datetime
import logging
import json
import os
# app = func.FunctionApp()


# @app.schedule(schedule="* 1 * * * *", arg_name="myTimer", run_on_startup=True,
#               use_monitor=False)
# def TimerTrigger(myTimer: func.TimerRequest) -> None:
#     utc_timestamp = datetime.datetime.utcnow().replace(
#         tzinfo=datetime.timezone.utc).isoformat()

#     if myTimer.past_due:
#         logging.info('The timer is past due!')

#     logging.info('Python timer trigger function ran at %s', utc_timestamp)

load_dotenv()
endpoint = os.getenv("ENDPOINT")
key = os.getenv("KEY")


formUrl = "https://cdn.discordapp.com/attachments/1118190224527335502/1152921940747616286/ALDT50_20221001.pdf"


def analyze_read():
    # sample document
    # formUrl = "https://raw.githubusercontent.com/Azure-Samples/cognitive-services-REST-api-samples/master/curl/form-recognizer/sample-layout.pdf"

    document_analysis_client = DocumentAnalysisClient(
        endpoint=endpoint, credential=AzureKeyCredential(key)
    )

    poller = document_analysis_client.begin_analyze_document_from_url(
        "prebuilt-document", formUrl)
    result = poller.result()

    for kv in result.key_value_pairs:
        if kv.key.content[-1] == ':' and kv.value:
            print("{} {}".format(
                kv.key.content, kv.value.content))
        elif kv.key and kv.value:
            print("{}: {}".format(
                kv.key.content, kv.value.content))
        else:
            print("{}".format(kv.key.content))

    dict = result.to_dict()

    json_object = json.dumps(dict, indent=4)
    with open("output.json", "w") as outfile:
        outfile.write(json_object)


analyze_read()
