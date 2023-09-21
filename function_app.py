from azure.core.credentials import AzureKeyCredential
from azure.ai.formrecognizer import DocumentAnalysisClient
from azure.storage.blob import ContainerClient
from azure.storage.fileshare import ShareDirectoryClient
import azure.functions as func
import logging
import json
import os

app = func.FunctionApp()


def call_form_recognizer(file):
    api_endpoint = os.getenv("ENDPOINT")
    api_key = os.getenv("KEY")
    document_analysis_client = DocumentAnalysisClient(
        endpoint=api_endpoint, credential=AzureKeyCredential(api_key)
    )
    poller = document_analysis_client.begin_analyze_document(
        "prebuilt-document", file)
    result = poller.result()

    return json.dumps(result.to_dict())


@app.schedule(schedule="0 30 9 * * 1-5", arg_name="myTimer", run_on_startup=False, use_monitor=True)
def TimerTrigger(myTimer: func.TimerRequest) -> None:

    if myTimer.past_due:
        logging.info("The timer is past due!")

    share_client = ShareDirectoryClient.from_connection_string(
        os.getenv("CONNECTION_STRING"), "pdf", "documents")

    blob_client = ContainerClient.from_connection_string(
        os.getenv("CONNECTION_STRING"), "output")

    for item in list(share_client.list_directories_and_files()):
        file_client = share_client.get_file_client(item["name"])

        if not file_client.get_file_properties().metadata:
            file = file_client.download_file().readall()
            output = call_form_recognizer(file)
            blob_client.upload_blob(
                item["name"].replace(".pdf", ".json"), output)
            file_client.set_file_metadata({"processed": "true"})
        else:
            logging.error("File %s is already processed", item["name"])
    share_client.close()
    blob_client.close()
