import json
import os
import time
import urllib.parse

import boto3


table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])


def _put(item_id, source, detail):
    now = int(time.time())
    table.put_item(
        Item={
            "id": item_id,
            "source": source,
            "detail": json.dumps(detail, separators=(",", ":"), sort_keys=True),
            "created_at": now,
            "expires_at": now + 3600,
        }
    )


def handler(event, context):
    records = event.get("Records") or []
    if records and records[0].get("eventSource") == "aws:s3":
        written = []
        for record in records:
            key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
            item_id = f"s3#{key}"
            _put(item_id, "s3", {"bucket": record["s3"]["bucket"]["name"], "key": key})
            written.append(item_id)
        return {"ok": True, "written": written}

    if event.get("source") == "chatgpt.aws.lab":
        detail = event.get("detail") or {}
        test_id = detail.get("test_id", event.get("id", context.aws_request_id))
        item_id = f"eventbridge#{test_id}"
        _put(item_id, "eventbridge", detail)
        return {"ok": True, "written": [item_id]}

    item_id = f"unknown#{context.aws_request_id}"
    _put(item_id, "unknown", event)
    return {"ok": True, "written": [item_id]}
