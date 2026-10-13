"""Group resource handlers."""

import json

import falcon

from vital.app.server.store import store
from vital.app.server.data import create_bundle, create_operation_outcome


class GroupCollection:
    """Handles GET /Group - Search for groups."""

    async def on_get(self, req: falcon.Request, resp: falcon.Response):
        """Search for Group resources.

        Supports search parameters:
        - identifier: Search by group identifier
        - characteristic: Search by group characteristic code
        - code: Search by group type code
        """
        identifier = req.get_param("identifier")
        characteristic = req.get_param("characteristic")
        code = req.get_param("code")

        groups = store.search_groups(
            identifier=identifier,
            characteristic=characteristic,
            code=code,
        )

        bundle = create_bundle(groups, bundle_type="searchset")

        resp.content_type = "application/fhir+json"
        resp.media = bundle


class GroupResource:
    """Handles GET /Group/{group_id} - Read a specific group."""

    async def on_get(self, req: falcon.Request, resp: falcon.Response, group_id: str):
        """Retrieve a specific Group resource by ID."""
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

        resp.content_type = "application/fhir+json"
        resp.media = group
