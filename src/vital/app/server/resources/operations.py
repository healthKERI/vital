"""FHIR operation handlers for Provider Access API."""

import falcon

from vital.app.server.store import store
from vital.app.server.data import (
    create_operation_outcome,
    generate_export_ndjson,
    generate_export_manifest,
    create_bundle,
)


class ProviderMemberMatch:
    """Handles POST /Group/$provider-member-match.

    Initiates an asynchronous member match operation.
    Returns 202 Accepted with Content-Location header pointing to status endpoint.
    """

    async def on_post(self, req: falcon.Request, resp: falcon.Response):
        """Initiate provider member match operation."""
        # Parse request body (Parameters resource)
        try:
            body = await req.get_media()
        except Exception:
            body = {}

        if body.get("resourceType") != "Parameters":
            # Accept requests without body for demo purposes
            pass

        # Create a task for the async operation
        task = store.create_task(
            task_type="provider-member-match",
            request_url="/Group/$provider-member-match",
        )

        task_id = task["id"]

        # Return 202 Accepted with Content-Location
        resp.status = falcon.HTTP_202
        resp.content_type = "application/fhir+json"
        resp.set_header(
            "Content-Location",
            f"/Group/provider-member-match-status/{task_id}"
        )
        resp.media = task


class ProviderMemberMatchStatus:
    """Handles GET /Group/provider-member-match-status/{task_id}.

    Returns the Task resource showing the status of the member match operation.
    """

    async def on_get(self, req: falcon.Request, resp: falcon.Response, task_id: str):
        """Check status of member match operation."""
        task = store.get_task(task_id)

        if task is None:
            resp.status = falcon.HTTP_404
            resp.content_type = "application/fhir+json"
            resp.media = create_operation_outcome(
                severity="error",
                code="not-found",
                diagnostics=f"Task with id '{task_id}' not found"
            )
            return

        # For demo purposes, mark task as completed after first status check
        if task["status"] == "in-progress":
            store.complete_task(task_id)
            task = store.get_task(task_id)

        # Add output reference when completed
        if task["status"] == "completed":
            task["output"] = [{
                "type": {
                    "coding": [{
                        "system": "http://hl7.org/fhir/us/davinci-pdex/CodeSystem/task-output-types",
                        "code": "member-match-result"
                    }]
                },
                "valueReference": {
                    "reference": f"/Group/$provider-member-match/response/{task_id}"
                }
            }]

        resp.content_type = "application/fhir+json"
        resp.media = task


class ProviderMemberMatchResponse:
    """Handles GET /Group/$provider-member-match/response/{task_id}.

    Returns the matched Group resources.
    """

    async def on_get(self, req: falcon.Request, resp: falcon.Response, task_id: str):
        """Get member match results."""
        task = store.get_task(task_id)

        if task is None:
            resp.status = falcon.HTTP_404
            resp.content_type = "application/fhir+json"
            resp.media = create_operation_outcome(
                severity="error",
                code="not-found",
                diagnostics=f"Task with id '{task_id}' not found"
            )
            return

        if task["status"] != "completed":
            resp.status = falcon.HTTP_202
            resp.content_type = "application/fhir+json"
            resp.set_header(
                "Content-Location",
                f"/Group/provider-member-match-status/{task_id}"
            )
            resp.media = task
            return

        # Return matched groups (for demo, return first available group)
        groups = store.search_groups()
        if groups:
            matched_groups = [groups[0]]  # Return first group as match
        else:
            matched_groups = []

        bundle = create_bundle(matched_groups, bundle_type="searchset")
        resp.content_type = "application/fhir+json"
        resp.media = bundle


class DavinciDataExport:
    """Handles POST /Group/{group_id}/$davinci-data-export.

    Initiates a bulk data export for the specified group.
    Returns 202 Accepted with Content-Location header pointing to status endpoint.
    """

    async def on_post(self, req: falcon.Request, resp: falcon.Response, group_id: str):
        """Initiate bulk data export."""
        # Verify group exists
        group = store.get_group(group_id)
        if group is None:
            resp.status = falcon.HTTP_404
            resp.content_type = "application/fhir+json"
            resp.media = create_operation_outcome(
                severity="error",
                code="not-found",
                diagnostics=f"Group with id '{group_id}' not found"
            )
            return

        # Create export content
        ndjson_content = generate_export_ndjson(group_id)
        download_token = store.create_export(ndjson_content)

        # Create task
        task = store.create_task(
            task_type="davinci-data-export",
            request_url=f"/Group/{group_id}/$davinci-data-export",
            group_id=group_id,
        )

        task_id = task["id"]

        # Store export info in task metadata
        task["meta"]["downloadToken"] = download_token

        # Return 202 Accepted
        resp.status = falcon.HTTP_202
        resp.content_type = "application/fhir+json"
        resp.set_header(
            "Content-Location",
            f"/Group/$davinci-data-export/status/{task_id}"
        )
        resp.media = task


class DavinciDataExportStatus:
    """Handles GET /Group/$davinci-data-export/status/{task_id}.

    Returns the export status/manifest.
    When complete, returns a manifest with download URLs.
    """

    async def on_get(self, req: falcon.Request, resp: falcon.Response, task_id: str):
        """Check status of bulk export operation."""
        task = store.get_task(task_id)

        if task is None:
            resp.status = falcon.HTTP_404
            resp.content_type = "application/fhir+json"
            resp.media = create_operation_outcome(
                severity="error",
                code="not-found",
                diagnostics=f"Task with id '{task_id}' not found"
            )
            return

        # For demo purposes, complete task on first status check
        if task["status"] == "in-progress":
            store.complete_task(task_id)
            task = store.get_task(task_id)

        if task["status"] == "completed":
            # Return export manifest
            download_token = task["meta"].get("downloadToken")
            group_id = task["meta"].get("groupId")
            request_url = task["meta"].get("requestUrl")

            manifest = generate_export_manifest(
                task_id=task_id,
                group_id=group_id,
                request_url=request_url,
                download_tokens=[("Patient", download_token)],
            )

            resp.status = falcon.HTTP_200
            resp.content_type = "application/json"
            resp.media = manifest
        else:
            # Still in progress
            resp.status = falcon.HTTP_202
            resp.content_type = "application/fhir+json"
            resp.set_header("X-Progress", "in-progress")
            resp.media = task
