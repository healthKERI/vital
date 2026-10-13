"""Download resource handler for bulk export files."""

import falcon

from vital.app.server.store import store
from vital.app.server.data import create_operation_outcome


class DownloadResource:
    """Handles GET /download/{token}.

    Returns the NDJSON file for a bulk export.
    """

    async def on_get(self, req: falcon.Request, resp: falcon.Response, token: str):
        """Download an export file."""
        content = store.get_export(token)

        if content is None:
            resp.status = falcon.HTTP_404
            resp.content_type = "application/fhir+json"
            resp.media = create_operation_outcome(
                severity="error",
                code="not-found",
                diagnostics=f"Export file with token '{token}' not found"
            )
            return

        resp.content_type = "application/fhir+ndjson"
        resp.text = content
