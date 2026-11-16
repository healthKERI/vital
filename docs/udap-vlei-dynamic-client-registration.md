  
Tools for Open API Ecosystems

# **UDAP vLEI Dynamic Client Registration**

**DRAFT**

## ---

**1\. Introduction**

Registration with an Authorization Server is typically required before a Client Application can access protected resources using the OAuth 2.0 authorization framework. For larger ecosystems with many clients and authorization servers, manual client registration presents a significant barrier. UDAP Dynamic Client Registration addresses this by extending OAuth 2.0 Dynamic Client Registration with a trust validation step.

This specification defines a parallel profile that uses **vLEI-chained ACDC credentials** conveyed via a **CESR-encoded stream** in place of X.509 certificate chains and signed JWT software statements. The Authorization Server permits registration only if the presented assertion is valid and trusted under local trust community policy.

This protocol is based upon standard Public Key Infrastructure augmented by the KERI (Key Event Receipt Infrastructure) protocol. Before granting registration, the Authorization Server validates the anchor (signed attestation in the issuer's key event log) of the vLEI-chained ACDC credential submitted by the Client App, and evaluates the trust chain for the Client App’s vLEI credential. Client registration is permitted only if the credential is valid and the Client App’s credential is trusted. This protocol MAY be used only by Client Apps that are able to protect the private key used to sign key events, e.g., confidential clients and certain native device apps.

Sections 1 through 5 define the steps of the workflow. Section 6 defines how previous registrations may be modified or canceled.

## **2\. Client checks UDAP support via server metadata**

The Client App checks that the Authorization Server supports UDAP by retrieving UDAP metadata from:

`GET /.well-known/udap`

This vLEI profile relies on the existing UDAP Server Metadata mechanism and extends it with vLEI/ACDC registration statement capabilities.

### **2.1 Required metadata elements for this profile (normative)**

An Authorization Server supporting this profile SHALL include (in addition to other applicable UDAP metadata):

> * vlei (if supporting dynamic registration)  
> * A metadata key identifying acceptable registration statement formats:

```json
{  
  "vlei": [  
    "{holder oobi}",  
    "{issuer oobi",  
    "{vlei oobi}"  
  ]  
}
```

If the Authorization Server returns an error code, then the Authorization Server does not support UDAP vLEI-based client authentication and the Client App should abort this workflow. The Authorization Server’s vLEI credentials are discovered as part of this metadata request. The Client App MAY examine the vLEI certificates to determine whether the Authorization Server is part of a suitable trust community.

## **3\. Client prepares a vLEI-chained ACDC credential**

The Client App prepares an ACDC (Authentic Chained Data Container) credential chained from a valid vLEI Legal Entity credential for submission. The credential serves three purposes: it provides the necessary metadata for registration, it establishes the Client App’s control of a private key, and it provides the verifiable credential needed to validate the signature and establish trust.

In this vLEI profile, the Client App prepares an **ACDC credential chained to a valid vLEI Legal Entity credential** as a:

> * **CESR-encoded stream**, and  
> * Embedding one or more **vLEI ACDC credentials** sufficient for the Authorization Server to validate:  
  1. the client operator identity (legal entity), and  
  2. authority to register this client (role / delegation as required by policy).

The ACDC Credential provides the capability to register for specific transactional use cases. Therefore an entity may have multiple ACDC credentials connected to their vLEI. 

### **3.1 Required semantic claims (normative)**

The vLEI-chained ACDC credential MUST carry, in its payload, semantics equivalent to the UDAP DCR credential JWT claims and required registration metadata.  
At minimum, the vLEI credential MUST provide:

> * **Issuer / Subject identity**: the client operator’s stable identifier (vLEI/KERI AID and/or LEI).  
> * **Audience**: the Authorization Server’s registration_endpoint URI.  
> * **Freshness / anti-replay**: issuance time \+ expiration (short-lived) and a unique token identifier (replay detection).  
> * **Registration parameters** (see Section 3.2), including client_name, redirect_uris, grant_types, response_types, scope (optional), and token_endpoint_auth_method.

### **3.2 Required registration parameters (normative)**

The vLEI credential MUST include the client registration metadata required by UDAP DCR, including:

> * client_name  
> * redirect_uris (required if grant_types includes authorization_code)  
> * grant_types (e.g., authorization_code, refresh_token, client_credentials)  
> * response_types (e.g., code; omit for pure client_credentials)  
> * scope (optional)  
> * token_endpoint_auth_method.

**Integration requirement (normative):**  
If the client intends to use the **UDAP vLEI ACDC Client Authentication** profile at the token endpoint, then the credential MUST set:

token_endpoint_auth_method \= "acdc_vlei"

## **4\. Client requests registration at the registration endpoint**

This profile uses, as the payload of its credential, the same top-level JSON structure as UDAP DCR, but changes the software_statement content to be the vLEI-chained ACDC credential CESR encoded string.

### **4.1 Registration request (normative)**

POST to the discovered registration_endpoint with:

> * software_statement: string, containing the **CESR-encoded vLEI-chained ACDC credential**  
> * software_statement_type: REQUIRED, value: urn:ietf:params:oauth:software-stateent-type:acdc-vlei  
> * udap: string value "1"  
> * credentials (optional)

Example (non-normative):

```bash
POST /register HTTP/1.1  
Host: as.example.com  
Content-type: application/json

{  
  "software_statement_type": "urn:ietf:params:oauth:software-statement-type:acdc-vlei",  
  "software_statement": "-VA0s[... remainder of CESR-encoded vLEI-chained ACDC credential omitted for brevity...]",  
  "credentials": [ "... optional ..." ],  
  "udap": "1"  
}
```

### **4.2 Credentials / endorsements (optional)**

In this vLEI profile, each entry in credentials SHOULD be:

> * a CESR-encoded vLEI ACDC credential that the ACDC credential is chained to

## **5\. Authorization Server validates request**

### **5.1 Validate vLEI-chained ACDC credential integrity and proof-of-control (normative)**

The Authorization Server MUST:

> 1. Parse CESR stream as a vLEI-chainded ACDC credential.  
> 2. Validate the ACDC credential message signature/anchor and confirm it proves control of the relevant AID.

### **5.2 Validate vLEI/ACDC chain trust (normative)**

The Authorization Server MUST validate embedded/referenced ACDC credentials and their chain to trust anchors recognized by the Authorization Server’s trust community policy.

### **5.3 Validate semantic fields (normative)**

The Authorization Server MUST validate that the ACDC content provides equivalent semantics, including:

> * issuer/subject stability (operator identifier)  
> * audience matches the server registration_endpoint  
> * unexpired, short-lived statement and issuance time window  
> * replay detection using a unique identifier

### **5.4 Validate registration parameters (normative)**

The Authorization Server MUST validate the registration parameters embedded in the credential as per dynamic registration rules and local policy. If invalid or required parameters are missing, the request is denied.

### **5.5 Replace prior registrations (optional)**

The Authorization Server MAY replace prior registrations associated with the same stable vLEI operator identifier.

## **6\. Authorization Server responds to request**

### **6.1 Success response (normative)**

If granted, the Authorization Server returns a registration response including a client_id issued by the AS, the submitted software_statement, and the effective registration parameters.  
Example (non-normative):

```json
HTTP/1.1 201 Created  
Content-Type: application/json

{  
  "client_id": "example_client_id_issued_by_AS",  
  "software_statement_type": "urn:ietf:params:oauth:client-assertion-type:acdc-vlei",  
  "software_statement": "-VA0s[...omitted...]",  
  "client_name": "Example Client",  
  "redirect_uris": ["https://client.example.org/callback"],  
  "grant_types": ["authorization_code"],  
  "response_types": ["code"],  
  "token_endpoint_auth_method": "acdc_vlei"  
}
```
**Integration requirement (normative):**  
The Authorization Server MUST store enough information from the validated vLEI/ACDC assertion(s) to validate subsequent token endpoint client authentication per **UDAP vLEI ACDC Client Authentication**.

### **6.2 Error response (normative)**

If denied, the Authorization Server returns an error. This profile reuses UDAP DCR-style error codes:

> * invalid_software_statement: ACDC/CESR parse failure, invalid signature/anchor, malformed statement  
> * unapproved_software_statement: vLEI/ACDC chain not trusted, required credentials missing, policy failure

Example (non-normative):

```json
{ "error": "unapproved_software_statement" }
```

## **7\. Modifying or Cancelling previous registrations**

This profile uses the same semantics as UDAP DCR, but the stable identifier is the client operator identity established by the vLEI/ACDC chain (e.g., LEI and/or controlling AID) carried in the vLEI credential.

### **7.1 Modify**

To modify a previous registration, the Client App operator SHALL submit a valid registration request that asserts the same stable operator identity but with updated registration parameters and/or updated credentials.

### **7.2 Cancel**

(*TODO:* should consider revocation)  
To cancel a previous registration, the Client App operator SHALL submit a valid registration request asserting the same stable operator identity but with an empty grant_types array.

## **8\. Normative integration with UDAP vLEI ACDC Client Authentication**

A client registered via this vLEI DCR profile and requesting token_endpoint_auth_method=acdc_vlei MUST authenticate at the token endpoint using:

> * client_assertion_type=urn:ietf:params:oauth:client-assertion-type:acdc-vlei  
> * client_assertion=\<CESR-encoded IPEX Grant\>

as defined in **UDAP vLEI ACDC Client Authentication**.

---

© 2025 UDAP.org (style-matched draft export)