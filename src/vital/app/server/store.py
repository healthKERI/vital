"""In-memory data store for FHIR resources."""

import uuid
from datetime import datetime, timezone
from typing import Any


class DataStore:
    """In-memory store for Groups, Tasks, and Exports."""

    def __init__(self):
        self.groups: dict[str, dict[str, Any]] = {}
        self.tasks: dict[str, dict[str, Any]] = {}
        self.exports: dict[str, str] = {}  # token -> ndjson content

    def get_group(self, group_id: str) -> dict[str, Any] | None:
        """Get a Group by ID."""
        return self.groups.get(group_id)

    def search_groups(
        self,
        identifier: str | None = None,
        characteristic: str | None = None,
        code: str | None = None,
    ) -> list[dict[str, Any]]:
        """Search Groups by parameters."""
        results = list(self.groups.values())

        if identifier:
            results = [
                g for g in results
                if any(
                    ident.get("value") == identifier
                    for ident in g.get("identifier", [])
                )
            ]

        if characteristic:
            results = [
                g for g in results
                if any(
                    char.get("code", {}).get("coding", [{}])[0].get("code") == characteristic
                    for char in g.get("characteristic", [])
                )
            ]

        if code:
            results = [
                g for g in results
                if g.get("code", {}).get("coding", [{}])[0].get("code") == code
            ]

        return results

    def create_task(
        self,
        task_type: str,
        request_url: str,
        group_id: str | None = None,
    ) -> dict[str, Any]:
        """Create a new Task resource."""
        task_id = f"task-{uuid.uuid4().hex[:8]}"
        now = datetime.now(timezone.utc).isoformat()

        task = {
            "resourceType": "Task",
            "id": task_id,
            "status": "in-progress",
            "intent": "order",
            "code": {
                "coding": [{
                    "system": "http://hl7.org/fhir/us/davinci-pdex/CodeSystem/task-codes",
                    "code": task_type,
                }]
            },
            "authoredOn": now,
            "lastModified": now,
            "meta": {
                "taskType": task_type,
                "requestUrl": request_url,
                "groupId": group_id,
            }
        }

        self.tasks[task_id] = task
        return task

    def get_task(self, task_id: str) -> dict[str, Any] | None:
        """Get a Task by ID."""
        return self.tasks.get(task_id)

    def complete_task(self, task_id: str) -> dict[str, Any] | None:
        """Mark a task as completed."""
        task = self.tasks.get(task_id)
        if task:
            task["status"] = "completed"
            task["lastModified"] = datetime.now(timezone.utc).isoformat()
        return task

    def create_export(self, content: str) -> str:
        """Create an export file and return its download token."""
        token = f"export-{uuid.uuid4().hex[:12]}"
        self.exports[token] = content
        return token

    def get_export(self, token: str) -> str | None:
        """Get export content by download token."""
        return self.exports.get(token)


# Global store instance
store = DataStore()
