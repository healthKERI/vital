Tools for Open API Ecosystems

# **VITAL SMART Permission Ticket Issuer Trust Profile**

**DRAFT**
## ---

**1\. Introduction**

SMART Permission Tickets provide a JWT artifact that a Client App presents to a Data Holder for token exchange. This specification defines how the Data Holder establishes the issuer's authority using KERI identifiers and vLEI-chained ACDC credentials.

The Ticket Issuer continues to sign ordinary Permission Ticket JWTs. This profile adds two discovery mechanisms and a common verification procedure: extensions on individual JWKs, and an extension in UDAP server metadata. Both mechanisms identify the same cryptographic evidence. An OOBI provides a means of discovering KERI material; it does not establish trust in an issuer or authorize a JWT signing key.

Before accepting a ticket, the Data Holder validates a binding between the ticket issuer URI, the actual JWT verification key, and a KERI AID. It then validates a separate **Permission Ticket Issuer Authorization ACDC** issued by an authority accepted under local trust community policy. Organizational identity alone does not confer permission to issue tickets.

This profile MAY be used only by issuers able to protect their JWT signing keys and the private keys controlling their KERI AIDs. Sections 2 through 6 define discovery and validation. Section 7 defines changes and revocation. Section 8 defines integration with client authentication. Sections 9 through 12 define security, examples, conformance, and references.

### **1.1 Conventions and draft status (normative)**

The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY, and OPTIONAL are interpreted as described in BCP 14 when they appear in uppercase.

All metadata names and credential semantics introduced here are proposed VITAL extensions. They are not registered JOSE parameters, standard UDAP metadata, or requirements of the base SMART Permission Tickets draft. Their publication does not imply acceptance by another implementation.

The profile identifier is `urn:vital:smart-permission-ticket-issuer-trust:1`. The proposed schema identifiers are `urn:vital:acdc:permission-ticket-key-binding:1` and `urn:vital:acdc:permission-ticket-issuer-authorization:1`. These identify semantic contracts in this draft; they are not ACDC schema SAIDs. A deploying trust community MUST publish concrete ACDC schemas and pin their SAIDs, KERI/ACDC/CESR protocol versions, credential edge rules, and approved authority roots before interoperable use. A verifier MUST NOT accept a credential merely because it asserts one of these strings.

### **1.2 Terms and roles**

> * **Ticket Issuer**: the operator signing the Permission Ticket JWT; identified in that JWT by `iss`.
> * **Issuer AID**: the KERI identifier authorized to operate that Ticket Issuer.
> * **Authorizing Authority**: an entity permitted by the trust community to grant ticket issuance authority.
> * **Key Binding ACDC**: a self-issued, registry-backed ACDC authenticating a particular JWT key's assignment to an Issuer AID and issuer URI.
> * **Issuer Authorization ACDC**: a credential granting that Issuer AID authority for specified ticket types and restrictions.
> * **Data Holder**: the relying party; its Authorization Server performs this profile's checks.

The Ticket Issuer, presenting client, subject, requester, and Authorizing Authority MAY be different parties. A verifier MUST preserve those distinctions.

## **2\. Data Holder checks issuer support via discovery metadata**

The Data Holder obtains candidate `iss` and protected-header `kid` values from the ticket. These values are untrusted until verification succeeds. The issuer URI MUST be an absolute HTTPS URI without query or fragment. Equality in this profile is exact, case-sensitive string equality; implementations MUST NOT merge issuer identities through URI normalization.

The baseline key publication location is `${iss}/.well-known/jwks.json`. Optional UDAP discovery begins at `${iss}/.well-known/udap`, using the publication convention of the referenced Permission Tickets draft, including any issuer path component. Deployments SHOULD use issuer URIs without a trailing slash to avoid ambiguous endpoint construction. Verifiers MUST use the exact configured construction rule and MUST NOT probe alternative issuer identities.

### **2.1 Per-JWK metadata elements (normative)**

A Ticket Issuer supporting per-JWK discovery SHALL include a `vital_keri` object on each covered public signing JWK. The object SHALL contain:

| Element | Type | Requirement |
|---|---|---|
| `profile` | string | Exact profile identifier from Section 1.1. |
| `issuer` | string | Exact ticket `iss`. |
| `aid` | string | Issuer AID. |
| `oobis` | array of strings | One or more discovery URLs for that AID. |
| `binding_said` | string | SAID of the Key Binding ACDC. |
| `authorization_said` | string | SAID of the Issuer Authorization ACDC. |
| `evidence_uri` | string | HTTPS endpoint returning the CESR evidence bundle in Section 4. |

These members are discovery hints until their values have been checked against authenticated evidence. The enclosing JWK SHALL include `kid`, `alg`, and `use: "sig"`. If `key_ops` is present it SHALL permit verification and SHALL NOT contradict that use. Private or symmetric key material MUST NOT be published.

The extension MUST NOT be included in the RFC 7638 thumbprint input. The verifier SHALL calculate the thumbprint from the required public members for the JWK's key type, using SHA-256 and unpadded base64url encoding.

### **2.2 UDAP metadata elements (normative)**

An issuer supporting UDAP discovery SHALL include a `vital_permission_ticket_issuer` object in its UDAP metadata. The object SHALL contain:

> * `profile`: the profile identifier.
> * `issuer`: the exact ticket issuer URI.
> * `jwks_uri`: an absolute HTTPS URI for the issuer's public signing JWK Set.
> * `keys`: a nonempty array of discovery entries.

Each `keys` entry SHALL contain `kid`, `jkt`, `alg`, `aid`, `oobis`, `binding_said`, `authorization_said`, and `evidence_uri`. The last five fields have the meanings in Section 2.1. `jkt` is the RFC 7638 SHA-256 thumbprint of the actual key; `kid` is only a selection hint. This profile does not define an issuer-wide default AID or default authorization credential.

Other applicable UDAP metadata remains governed by the selected UDAP profile. An existing `vlei` member MAY provide additional discovery hints; it MUST NOT replace the binding and authorization evidence required here. Implementations MUST NOT claim conventional X.509-based UDAP conformance solely because this extension is published at a UDAP endpoint.

If a deployment uses UDAP `signed_metadata`, it MUST validate that artifact under the selected UDAP profile. The artifact authenticates these extensions only when its verified payload actually covers their values. An unsigned sibling of a signed field is not thereby authenticated. Neither an ordinary HTTPS response nor an X.509 metadata signature alone establishes the required KERI binding.

### **2.3 Selection, precedence, and conflicts (normative)**

Local trust community policy SHALL select `per_jwk`, `udap`, or `both` discovery before processing untrusted metadata. A deployment MAY configure a permitted fallback route in advance. An attacker-controlled response MUST NOT enable a route forbidden by policy.

The Data Holder MUST apply these rules:

> 1. Select a unique key using the protected `kid`, approved algorithm, and applicable issuer key set. Reject ambiguous duplicate `kid` values; never try an unrelated key merely because it verifies the signature.
> 2. Per-JWK metadata supplies the key-specific candidate when available. Otherwise a matching UDAP entry supplies the candidate, provided that route is permitted. Per-JWK selection precedence does not override a conflict.
> 3. When both routes are required, retrieve both successfully. When both are retrieved under any mode, compare every applicable entry for the selected `kid` and actual key thumbprint. Reject malformed entries, ambiguous entries, or disagreement in `issuer`, `aid`, `jkt`, `alg`, `binding_said`, or `authorization_said`. For a per-JWK entry, derive `jkt` from its enclosing key.
> 4. Different `oobis`, `evidence_uri`, or JWKS locations MAY identify replicas. Each accepted location MUST resolve to evidence for the same authenticated tuple. An endpoint does not acquire authority merely because it appears in both documents.
> 5. If a conflict may reflect publication delay, perform at most one bounded refresh of the relevant documents and evidence. Reject if the conflict remains. Do not downgrade to ordinary JWKS trust, X.509-only trust, or a route that omits a required check.
> 6. Compare every candidate to the authenticated Key Binding ACDC. The authenticated evidence controls acceptance, but MUST NOT silently repair contradictory metadata.

If only one route is configured, the Data Holder need not fetch the other. A missing optional endpoint is not itself a conflict. A failure or invalid proof on a required route SHALL cause rejection. If an optional route returns applicable contradictory metadata, the Data Holder SHALL reject rather than ignore the contradiction.

## **3\. Ticket Issuer prepares vLEI-chained ACDC credentials**

### **3.1 Required key binding claims (normative)**

The Ticket Issuer SHALL prepare a Key Binding ACDC issued by the Issuer AID to itself. It SHALL carry these semantics in schema-defined attributes:

| Claim | Required semantics |
|---|---|
| `profile` | This profile's identifier. |
| `issuer` | Exact Permission Ticket `iss` URI. |
| `aid` | Same AID as both ACDC issuer and subject. |
| `kid` | Exact protected-header key identifier. |
| `jkt` | RFC 7638 SHA-256 thumbprint of the authorized JWT public key. |
| `alg` | One explicitly authorized JOSE algorithm for that key. |
| `purpose` | Exact string `smart-permission-ticket-signing`. |
| `authorization_said` | Exact Issuer Authorization ACDC SAID. |
| `not_before`, `expires_at` | Integer UTC NumericDate values defining a nonempty validity interval. |

The credential's authenticated issuance record SHALL commit to its SAID through the credential registry and an accepted KERI key event anchor. The verifier MUST validate the issuance record, registry state, anchor, and controlling key event history under the community's pinned protocol versions. Merely verifying a digest, reading an anchor string, or trusting an OOBI response is insufficient.

This is an explicit authorization of an application signing key. The JWT key need not be a key in the AID's KEL. No equality between KERI key material and JOSE key material is assumed. Possession of the JWT private key is demonstrated by the ticket signature; authority to associate that public key with the AID is demonstrated by the authenticated binding credential. An unanchored self-asserted JSON document is not a binding credential.

### **3.2 Required issuer authorization claims (normative)**

The Authorizing Authority SHALL issue a registry-backed Permission Ticket Issuer Authorization ACDC to the Issuer AID. The credential SHALL provide:

> * The exact authorized `issuer` URI and subject `aid`.
> * This profile identifier and a nonempty set of permitted `ticket_types` URI values.
> * A nonempty set of permitted `audiences`, each containing an audience value and its audience interpretation.
> * Explicit maximum SMART permissions (`scope_ceiling`), interpreted as permissions rather than string prefixes.
> * `max_ticket_lifetime` in positive integer seconds.
> * Integer UTC `not_before` and `expires_at` bounds.
> * An explicit `delegation_allowed` boolean.
> * Authenticated credential edges sufficient to establish the subject's vLEI organizational identity and the authority's permission to grant this issuance authority.

The schema MAY additionally constrain jurisdiction, requester classes, presenting-client populations, data categories, verification obligations, or continuation. Each such restriction MUST have pinned, executable evaluation semantics. An absent optional restriction adds no restriction from that credential; it never overrides a restriction from an upstream credential or local policy.

If delegation is allowed, the schema SHALL define maximum delegation depth and permitted child restrictions. Each child grant MUST be a subset of its parent's authority. A verifier MUST reject unauthorized delegation, cycles, unknown critical restrictions, and restrictions it cannot evaluate. No delegation is permitted when `delegation_allowed` is false.

The legal entity identity chain and the issuance-authority chain MAY have different roots. Both SHALL terminate at roots accepted for their respective purposes. A vLEI identity credential does not by itself grant ticket issuance authority.

### **3.3 Credential linkage (normative)**

The binding's `authorization_said` MUST identify the exact authorization credential selected in metadata. That credential's subject AID and issuer URI MUST equal those in the binding. The AID controlling the binding MUST therefore be the authorized operator, not merely the Authorizing Authority or a related legal entity.

## **4\. Ticket Issuer publishes evidence**

### **4.1 Evidence response (normative)**

The issuer SHALL make the referenced evidence available without requiring patient information or the ticket itself. An HTTP GET to `evidence_uri` SHALL return a CESR stream containing the binding and authorization credentials and the supporting material required by the community's pinned protocols. The deployment SHALL specify the supported CESR representation and HTTP media type; this draft does not allocate a media type.

The evidence MUST enable validation of credential SAIDs, schemas, registry issuance and revocation state, KEL anchors, relevant historical key events, delegation proofs where applicable, credential edges, and required witness or backer evidence. Missing dependencies MAY be obtained through approved resolvers. A verifier MUST NOT treat the bundle's own claim of completeness or currency as proof.

No new universal credential-query protocol is defined here. `evidence_uri` is an explicit retrieval endpoint. An OOBI SHALL be used to bootstrap KERI resolution; it MUST NOT be assumed to retrieve a credential simply because its SAID is known. Authenticated evidence MAY be transported by an untrusted mirror.

### **4.2 Freshness and trust policy (normative)**

The community SHALL define a maximum status age, accepted evidence sources, clock skew, and recovery procedure. In the absence of a stricter configured value, this profile sets maximum status age to 300 seconds and clock skew to 60 seconds.

Status age is elapsed time since a successful synchronization against policy-approved sources, not the age of the last KEL or registry event. Retrieval time from an arbitrary mirror does not prove current status. A verifier MUST obtain state under the community's configured KERI receipt, witness, backer, or independent-source policy and detect rollback against previously accepted state. If adequate freshness cannot be established, it MUST reject the ticket.

## **5\. Data Holder validates ticket and issuer authority**

### **5.1 Validate key binding integrity and proof-of-control (normative)**

The Authorization Server MUST:

> 1. Parse the JWT and protected header with duplicate-member rejection and bounded input sizes. Require an approved asymmetric `alg` and a nonempty `kid`.
> 2. Discover and select the public key and evidence under Section 2. Reject `none`, symmetric algorithms, key-type confusion, and incompatible JWK parameters.
> 3. Compute the selected key's thumbprint. Validate the Key Binding ACDC, its approved schema, registry issuance, current status, and KERI anchor and history.
> 4. Check exact equality of `issuer`, `aid`, `kid`, `jkt`, `alg`, `purpose`, and `authorization_said` against the selected metadata, ticket, actual public key, and authorization credential.
> 5. Verify the JWT signature using that public key and the algorithm authorized by both local policy and the binding. No key obtained through an unapproved token-header URL may replace it.

Discovery may precede signature verification to locate the key. No ticket claim SHALL be trusted, and no access token SHALL be issued, until all required checks complete.

### **5.2 Validate vLEI/ACDC chain trust (normative)**

The Authorization Server MUST validate credential integrity, schema SAIDs, edge semantics, issuance anchors, and status throughout every required chain. It MUST establish legal entity identity and the Authorizing Authority's authority for the particular grant. It MUST validate historical KERI signing thresholds, authorized delegation, and community-required receipts; a current key list alone is insufficient to validate a historical anchor.

The verifier MUST reject unresolved duplicity or inconsistent registry histories under its trust policy. Trust anchors MUST come from local configuration or an independently authenticated community update, never solely from the discovered bundle.

### **5.3 Validate semantic fields (normative)**

The Authorization Server MUST require `iat` in tickets accepted under this profile. Both credentials MUST be valid at `iat` and at redemption time, allowing only the configured clock skew. The ticket MUST NOT have a future issuance time beyond that skew. Ticket expiration MUST NOT exceed either credential's expiration, and `exp - iat` MUST NOT exceed the authorization's `max_ticket_lifetime`.

The ticket's type and intended audience MUST fall within the authorization grant. For framework audiences, membership validation SHALL use the applicable framework rules. A framework identifier alone is not membership evidence. Scope ceilings and any additional constraints SHALL be applied using their defined semantics. The Data Holder MUST reject a ticket that asserts authority outside its issuer's grant; merely issuing a narrower token does not cure that invalid assertion.

The Data Holder MUST NOT interpret `iat` as an independently trustworthy signing timestamp. This profile requires current authority at redemption and does not permit historical acceptance of a currently revoked binding based on a ticket's claimed issuance time.

### **5.4 Validate Permission Ticket and access parameters (normative)**

After establishing issuer trust, the Data Holder SHALL perform all validation required by the selected SMART Permission Ticket revision and ticket-type profile. That includes audience eligibility, subject resolution, presenter binding, ticket lifecycle checks, and access calculation.

The final access grant SHALL be no broader than the issuer authorization ceiling, ticket constraints, client eligibility, requested permissions, and local policy. The Data Holder SHALL deny access when a required constraint cannot be enforced.

## **6\. Authorization Server responds to request**

### **6.1 Success response (normative)**

If all checks succeed, the Authorization Server returns the token-exchange response defined by the applicable SMART Permission Ticket and OAuth specifications. This profile adds no required token-response member.

**Integration requirement (normative):**

The Authorization Server MUST retain sufficient audit information to associate the decision with issuer URI, Issuer AID, key thumbprint, binding SAID, authorization SAID, evaluated credential states, ticket identifier, effective permissions, and trust-policy version. Audit records SHOULD minimize patient data.

### **6.2 Error response (normative)**

Invalid, expired, revoked, untrusted, conflicting, or unavailable issuer evidence SHALL cause ticket rejection with `invalid_grant`. The server SHALL preserve applicable OAuth errors for malformed token requests, unsupported grants, and failed client authentication. An issuer-trust failure is not a client-authentication failure.

Example (non-normative):

```json
{
  "error": "invalid_grant",
  "error_description": "Permission ticket issuer trust validation failed"
}
```

Detailed causes SHOULD be recorded in protected logs. Public errors MUST NOT disclose patient information, private resolver topology, or credential material.

## **7\. Modifying or Cancelling previous bindings and authorizations**

### **7.1 Modify / JWT signing-key rotation (normative)**

A new JWT public key requires a new Key Binding ACDC and a new `kid`. The issuer SHALL publish the new evidence and applicable metadata before issuing tickets under the new key. During a planned overlap it MAY retain both keys and their valid bindings. Each is evaluated independently.

Removing a key from a JWKS is not an authenticated revocation event. A verifier MUST NOT use a removed cached key for new redemptions unless community policy explicitly permits retained-key verification and its binding and authorization remain current. Issuers SHOULD retain old public keys through the last affected ticket expiration. Cache lifetimes SHALL be bounded by credential expiration, HTTP limits, and maximum status age.

### **7.2 KERI key rotation and identity changes (normative)**

Ordinary KERI rotation under the same AID does not require replacing a JWT key or binding. The verifier SHALL preserve historical validation while updating the AID's accepted state. Rotation of the JWT key does not require rotation of the AID.

Changing the Issuer AID, issuer URI, authorization SAID, or binding claims requires new credentials and metadata. Similar legal entity names or an identical LEI MUST NOT automatically transfer issuance authority to a new AID. A successor identity requires an explicit grant accepted by the community.

### **7.3 Cancel / credential revocation (normative)**

The binding controller SHALL revoke a compromised or withdrawn Key Binding ACDC through its authenticated credential registry. The Authorizing Authority SHALL revoke an Issuer Authorization ACDC when issuance authority is withdrawn. Revocation of a required ancestor or applicable delegation SHALL invalidate dependent acceptance once established under the community's status policy.

A verifier MUST reject all new redemptions using a currently revoked binding or authorization, even if the ticket claims an earlier `iat`. A cached previously valid result MUST NOT override known revocation. Ordinary KERI rotation does not revoke these credentials automatically; credential revocation does not rotate KERI keys automatically.

### **7.4 Ticket revocation and derived tokens (normative)**

Issuer-credential revocation and individual-ticket revocation are separate checks. Neither replaces the other. The Data Holder SHALL perform the ticket's required status checks independently of credential registry checks.

For refresh or other continuing grants, the Data Holder SHALL retain the source ticket and issuer-evidence association and re-evaluate this profile before each refresh. This profile requires denying refresh after binding or authorization revocation. Locally issued access tokens already in use require a local invalidation mechanism if immediate termination is required; credential revocation alone does not invalidate a self-contained access token at a Resource Server.

## **8\. Normative integration with UDAP vLEI ACDC Client Authentication**

The client-authentication artifact and the Permission Ticket SHALL remain separate. A deployment MAY combine this issuer-trust profile with VITAL dynamic client registration and ACDC client authentication. Such support SHALL be configured at the token endpoint; issuer discovery metadata alone does not enable it.

The issuer's binding proves the ticket signer's authority. It MUST NOT be used as proof of the presenting client's identity or possession of a client key. A client AID alone does not satisfy a presenter restriction expressed as a JWK thumbprint. Where a ticket requires a particular client key, the Data Holder MUST obtain accepted proof of possession of that exact key. If its authentication method cannot establish the required presenter semantics, it SHALL reject the ticket.

This draft does not introduce a new SMART `presenter_binding` method or framework type. Deployment-specific mapping from ACDC-authenticated client identity to an existing framework binding requires a separately defined and accepted profile.

## **9\. Security considerations**

### **9.1 Discovery and substitution (normative)**

An attacker controlling HTTPS discovery cannot authorize a replacement key without valid binding and authorization evidence. Verifiers MUST check the complete issuer/AID/key/algorithm/credential tuple. Key identifiers, DNS ownership, OOBI URLs, certificate subjects, and vLEI identity alone MUST NOT substitute for this check.

All discovery retrieval SHALL enforce SSRF protections, approved schemes and ports, DNS/address checks at connection time, bounded redirects, timeouts, and response-size limits. Redirects MUST NOT bypass address policy or change the issuer identity. Resolution SHALL use allowlisted or explicitly permitted destinations and MUST NOT send patient-bearing tickets to discovery endpoints. Implementations MUST bound credential graph depth, dependency count, CESR parsing, and decompression.

### **9.2 Downgrade, replay, and stale state (normative)**

Once local policy requires this profile for an issuer, failure MUST NOT trigger acceptance through a weaker trust mechanism. Metadata cannot disable a configured check. Verifiers SHALL pin supported profile versions and reject incompatible versions.

An old valid bundle is insufficient evidence of current authority. Verifiers SHALL maintain rollback-resistant accepted KERI and registry state and apply Section 4.2. A ticket identifier is an audit correlation value, not by itself a one-time-use requirement; implementations SHALL preserve the base ticket's permitted reuse behavior. Client-authentication replay defenses remain governed by the selected authentication profile.

### **9.3 Operational boundaries (normative)**

Issuer JWT keys SHOULD be separated from KERI controller keys and from metadata-signing keys. Key compromise SHALL trigger credential revocation and cache invalidation under a documented incident procedure. A compromised JWT key can forge `iat`; backdating MUST NOT bypass current revocation checks.

Credentials and public evidence SHOULD contain organizational authorization information only. Patient identity, consent records, and underlying verification documents SHOULD NOT be published in public KELs, credential registries, or discovery bundles. Acceptance of issuer authority does not establish the truth of every ticket assertion or remove the Data Holder's policy obligations.

## **10\. Examples**

All examples in this section are non-normative templates. Angle-bracket strings are placeholders, not valid AIDs, SAIDs, thumbprints, signatures, or key coordinates. They MUST be replaced with cryptographically generated values. The objects illustrate discovery and credential semantics; they are not signed test vectors.

### **10.1 Per-JWK discovery**

```json
{
  "keys": [{
    "kty": "EC",
    "crv": "P-256",
    "x": "<public-x>",
    "y": "<public-y>",
    "kid": "ticket-key-2026-11",
    "alg": "ES256",
    "use": "sig",
    "vital_keri": {
      "profile": "urn:vital:smart-permission-ticket-issuer-trust:1",
      "issuer": "https://tickets.example.org",
      "aid": "<issuer-aid>",
      "oobis": ["https://keri.example.org/oobi/<issuer-aid>/witness"],
      "binding_said": "<binding-said>",
      "authorization_said": "<authorization-said>",
      "evidence_uri": "https://tickets.example.org/evidence/<binding-said>"
    }
  }]
}
```

### **10.2 UDAP metadata discovery**

This is the extension fragment of a metadata response. Applicable ordinary UDAP members are omitted.

```json
{
  "vital_permission_ticket_issuer": {
    "profile": "urn:vital:smart-permission-ticket-issuer-trust:1",
    "issuer": "https://tickets.example.org",
    "jwks_uri": "https://tickets.example.org/.well-known/jwks.json",
    "keys": [{
      "kid": "ticket-key-2026-11",
      "jkt": "<sha256-jwk-thumbprint>",
      "alg": "ES256",
      "aid": "<issuer-aid>",
      "oobis": ["https://keri.example.org/oobi/<issuer-aid>/witness"],
      "binding_said": "<binding-said>",
      "authorization_said": "<authorization-said>",
      "evidence_uri": "https://tickets.example.org/evidence/<binding-said>"
    }]
  }
}
```

### **10.3 Authenticated credential attributes**

These are semantic attribute projections. A real ACDC requires its schema, SAID-bearing envelope, registry references, credential edges, and CESR evidence; sending these JSON objects alone SHALL NOT satisfy this profile.

Key Binding ACDC attributes:

```json
{
  "profile": "urn:vital:smart-permission-ticket-issuer-trust:1",
  "issuer": "https://tickets.example.org",
  "aid": "<issuer-aid>",
  "kid": "ticket-key-2026-11",
  "jkt": "<sha256-jwk-thumbprint>",
  "alg": "ES256",
  "purpose": "smart-permission-ticket-signing",
  "authorization_said": "<authorization-said>",
  "not_before": 1795046400,
  "expires_at": 1797638400
}
```

Issuer Authorization ACDC attributes:

```json
{
  "profile": "urn:vital:smart-permission-ticket-issuer-trust:1",
  "issuer": "https://tickets.example.org",
  "aid": "<issuer-aid>",
  "ticket_types": [
    "https://smarthealthit.org/permission-ticket-type/patient-self-access-v1"
  ],
  "audiences": [{
    "value": "https://fhir.example.org",
    "aud_type": "data_holder_url"
  }],
  "scope_ceiling": ["patient/Observation.rs"],
  "max_ticket_lifetime": 3600,
  "delegation_allowed": false,
  "not_before": 1795046400,
  "expires_at": 1797638400
}
```

The Authorizing Authority issues the second credential to `<issuer-aid>`. The Issuer AID issues the first credential to itself. Their authenticated edges and supporting credentials establish the separate identity and issuance-authority chains.

### **10.4 Acceptance and rejection cases**

| Case | Required outcome |
|---|---|
| Per-JWK route permitted; exact tuple and both credentials validate | Continue ticket validation. |
| UDAP route permitted; JWK has no extension; matching UDAP entry validates | Continue ticket validation. |
| Both routes identify different authorization SAIDs | Reject after the bounded refresh. |
| Same `kid` but different actual public key | Reject thumbprint mismatch. |
| AID resolves but no authenticated key binding exists | Reject. |
| Valid legal entity identity without ticket issuance authority | Reject. |
| Valid binding but ticket type exceeds the authorization | Reject. |
| JWT key is rotated while the old binding remains valid | Evaluate each key independently under Section 7.1. |
| Binding is revoked and ticket claims an earlier `iat` | Reject new redemption. |
| Credential status cannot be established within freshness policy | Reject. |

## **11\. Conformance requirements**

An issuer claiming conformance SHALL publish baseline JWKS, support at least one discovery route, and provide authenticated binding and authorization evidence. A verifier claiming conformance SHALL support both discovery formats, MAY restrict their use by community policy, and SHALL implement the conflict, cryptographic, status, and authorization checks above.

Before production interoperability, a community SHALL publish the concrete schema SAIDs and evidence transport choices required by Section 1.1, trusted authority roles, allowed algorithms, scope and audience semantics, status-source policy, and continuation behavior. Test material SHALL include valid generated evidence and negative cases covering key substitution, conflicting metadata, unauthorized delegation, revoked ancestors, stale registry state, and unsupported constraints.

## **12\. References and relationship to source specifications**

This draft uses the presentation conventions of the VITAL registration document and defines an independent issuer-trust extension. It does not amend either source specification. Sources reviewed on 19 November 2026; deployments SHALL pin the revisions they implement because the Permission Tickets source is a work in progress.

> * [VITAL UDAP vLEI Dynamic Client Registration](https://github.com/healthKERI/vital/blob/main/docs/udap-vlei-dynamic-client-registration.md) — companion profile and editorial model.
> * [SMART Permission Tickets draft](https://github.com/jmandel/smart-permission-tickets-wip/blob/main/input/pagecontent/index.md) — ticket format, issuer publication, token exchange, and redemption processing.
> * [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) — normative terminology.
> * [RFC 7517](https://www.rfc-editor.org/rfc/rfc7517), [RFC 7515](https://www.rfc-editor.org/rfc/rfc7515), and [RFC 7519](https://www.rfc-editor.org/rfc/rfc7519) — JWK, JWS, and JWT.
> * [RFC 7638](https://www.rfc-editor.org/rfc/rfc7638) — public-key thumbprints.
> * [RFC 8725](https://www.rfc-editor.org/rfc/rfc8725) — JWT security practices.
> * [RFC 8693](https://www.rfc-editor.org/rfc/rfc8693) and [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749) — token exchange and OAuth responses.
> * [KERI specification repository](https://github.com/trustoverip/tswg-keri-specification), [ACDC specification repository](https://github.com/trustoverip/tswg-acdc-specification), and [CESR specification repository](https://github.com/trustoverip/tswg-cesr-specification) — deployment-pinned evidence and validation protocols.

---

VITAL working draft — 19 November 2026
