import os, logging, json, asyncio
import azure.functions as func

from azure.servicebus.aio import ServiceBusClient
from azure.servicebus import ServiceBusMessage

CONNECTION_STR = os.environ['SERVICE_BUS_CONNECTION_STR']
QUEUE_NAME = os.environ["SERVICE_BUS_QUEUE_NAME"]

async def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('[HTTPTrigger(cancel)]Python HTTP trigger has received a ServiceBus cancellation request.')

    body = json.loads(req.get_body().decode())
    sequence_numbers = body['sequence_numbers']
    logging.info(f'[HTTPTrigger(cancel)]sequence_numbers: {sequence_numbers}')
    servicebus_client = ServiceBusClient.from_connection_string(conn_str=CONNECTION_STR, logging_enable=True)
    async with servicebus_client:
        sender = servicebus_client.get_queue_sender(queue_name=QUEUE_NAME)
        async with sender:
            msg= await sender.cancel_scheduled_messages(sequence_numbers)
            logging.info(msg)

    return func.HttpResponse(f"Successfully cancelled jobs of sequence IDs: {sequence_numbers} from the ServiceBus.")

