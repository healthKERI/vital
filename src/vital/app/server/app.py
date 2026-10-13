"""FHIR Provider Access HTTP Server.

This module provides an asyncio ASGI/Falcon-based HTTP server that implements
the Provider Access API defined in the FHIR CapabilityStatement.
"""

import argparse
import json

import falcon.asgi
from falcon import media

from vital.app.server.data import init_sample_data
from vital.app.server.resources.group import GroupCollection, GroupResource
from vital.app.server.resources.operations import (
    ProviderMemberMatch,
    ProviderMemberMatchStatus,
    ProviderMemberMatchResponse,
    DavinciDataExport,
    DavinciDataExportStatus,
)
from vital.app.server.resources.download import DownloadResource


class CORSMiddleware:
    """CORS middleware for cross-origin requests."""

    async def process_request(self, req: falcon.Request, resp: falcon.Response):
        """Process incoming request - add CORS headers."""
        resp.set_header("Access-Control-Allow-Origin", "*")
        resp.set_header(
            "Access-Control-Allow-Methods",
            "GET, POST, PUT, DELETE, OPTIONS"
        )
        resp.set_header(
            "Access-Control-Allow-Headers",
            "Content-Type, Authorization, Accept, Prefer"
        )
        resp.set_header("Access-Control-Max-Age", "86400")

    async def process_response(
        self,
        req: falcon.Request,
        resp: falcon.Response,
        resource,
        req_succeeded: bool
    ):
        """Process outgoing response."""
        pass


def create_app() -> falcon.asgi.App:
    """Create and configure the Falcon ASGI application."""
    # Initialize sample data
    init_sample_data()

    # Create app with CORS middleware
    app = falcon.asgi.App(middleware=[CORSMiddleware()])

    # Add FHIR media type handlers
    json_handler = media.JSONHandler()
    extra_handlers = {
        "application/fhir+json": json_handler,
        "application/fhir+ndjson": json_handler,
    }
    app.req_options.media_handlers.update(extra_handlers)
    app.resp_options.media_handlers.update(extra_handlers)

    # Group resources
    group_collection = GroupCollection()
    group_resource = GroupResource()

    # Operation resources
    member_match = ProviderMemberMatch()
    member_match_status = ProviderMemberMatchStatus()
    member_match_response = ProviderMemberMatchResponse()
    data_export = DavinciDataExport()
    data_export_status = DavinciDataExportStatus()

    # Download resource
    download = DownloadResource()

    # Register routes
    # Group search and read
    app.add_route("/Group", group_collection)
    app.add_route("/Group/{group_id}", group_resource)

    # Provider Member Match operation
    app.add_route("/Group/$provider-member-match", member_match)
    app.add_route(
        "/Group/provider-member-match-status/{task_id}",
        member_match_status
    )
    app.add_route(
        "/Group/$provider-member-match/response/{task_id}",
        member_match_response
    )

    # DaVinci Data Export operation
    app.add_route("/Group/{group_id}/$davinci-data-export", data_export)
    app.add_route("/Group/$davinci-data-export/status/{task_id}", data_export_status)

    # Download endpoint
    app.add_route("/download/{token}", download)

    return app


# Create the ASGI application instance
app = create_app()


def main():
    """Entry point for running the server via CLI."""
    parser = argparse.ArgumentParser(
        description="FHIR Provider Access HTTP Server"
    )
    parser.add_argument(
        "--host",
        default="127.0.0.1",
        help="Host to bind to (default: 127.0.0.1)"
    )
    parser.add_argument(
        "--port",
        type=int,
        default=8080,
        help="Port to bind to (default: 8080)"
    )
    parser.add_argument(
        "--reload",
        action="store_true",
        help="Enable auto-reload on code changes"
    )

    args = parser.parse_args()

    try:
        import uvicorn
    except ImportError:
        print("Error: uvicorn is not installed.")
        print("Install it with: pip install 'vital[server]'")
        return 1

    print(f"Starting FHIR Provider Access Server on http://{args.host}:{args.port}")
    print("Available endpoints:")
    print("  GET  /Group                                    - Search groups")
    print("  GET  /Group/{group_id}                         - Read group")
    print("  POST /Group/$provider-member-match             - Member match")
    print("  GET  /Group/provider-member-match-status/{id}  - Match status")
    print("  GET  /Group/$provider-member-match/response/{id} - Match results")
    print("  POST /Group/{group_id}/$davinci-data-export    - Start export")
    print("  GET  /Group/$davinci-data-export/status/{id}   - Export status")
    print("  GET  /download/{token}                         - Download file")
    print()

    uvicorn.run(
        "vital.app.server.app:app",
        host=args.host,
        port=args.port,
        reload=args.reload,
    )

    return 0


if __name__ == "__main__":
    exit(main())
