  
Tools for Open API Ecosystems

# **UDAP vLEI/ACDC Client Authentication**

**DRAFT**

## ---

**1\. Introduction**

The verifiable Legal Entity Identifier (vLEI), developed by the Global Legal Entity Identifier Foundation (GLEIF), offers a path towards a universally recognized, verifiable organizational identifier in healthcare. The LEI system is already used globally in financial markets to identify legal entities. Many healthcare organizations already have an LEI. The vLEI extends this into a digital, cryptographically verifiable credential that binds an organization’s identity to a secure key pair.

This specification defines a UDAP client authentication profile for OAuth 2.0 token endpoints that uses **vLEI-chained ACDC credentials**, conveyed via a **CESR-encoded IPEX Grant message**, in place of X.509 certificates or JWT-based client assertions.  
This profile is modeled directly on the **UDAP JWT-Based Client Authentication** specification and is intended to be semantically equivalent, differing only in the cryptographic assertion format and verification mechanism. In addition, it provides extended capabilities through the use of KERI (Key Event Receipt Infrastructure) identifier delegation.

Before granting an access token, the Authorization Server uses standard Public Key Infrastructure tools to validate the digital signature on the IPEX grant submitted by the Client App, and to evaluate the trust chain for the Client App’s vLEI. The access token is granted by the Authentication Server only if the IPEX grant is valid (see Section 6\) and the Client App’s vLEI is trusted. This protocol SHALL only be used only by Client Apps that are able to protect the private key used to sign IPEX grants, e.g. confidential clients and certain native device apps.  
This profile supports client authentication at the token endpoint for both:

> * Authorization Code Flow  
> * Client Credentials Flow

## **2\. Client Assertion Type**

This profile defines a new OAuth client assertion type:

urn:ietf:params:oauth:client-assertion-type:acdc-vlei

This value SHALL be used as the client_assertion_type parameter when the client authenticates to the token endpoint using a vLEI credential.

## **3\. Authorization Server Metadata**

Authorization Servers supporting this profile SHALL include the following value in the token_endpoint_auth_methods_supported metadata element returned from:

```json
GET /.well-known/udap

{  
  "vlei": [  
    "{holder oobi}",  
    "{issuer oobi",  
    "{vlei oobi}"  
  ]  
}
```

If the Authorization Server returns an error code, then the Authorization Server does not support UDAP JWT-based client authentication and the Client App should abort this workflow. The Authorization Server’s vLEI credentials are discovered as part of this metadata request. The Client App MAY examine the vLEI certificates to determine whether the Authorization Server is part of a suitable trust community.

## **4\. Client Registration Requirements**

Clients intending to use this profile MUST be registered with the Authorization Server to use signed IPEX grants as Authentication Tokens, unless the Client App and Authorization Server support the alternative flow for unregistered client apps described in section 10.1. If the Authorization Server supports UDAP vLEI-based Dynamic Client Registration, the Client App MAY register with the AS using that protocol. If the AS does not support dynamic client registration, it SHOULD supply another method for Client Apps to register their vLEI and get a client ID.

The Authorization Server SHALL bind the registered client_id to the vLEI holder KERI identifier and will allow identifiers to sign IPEX grant messages, according to policy:

> * Holder of an accepted vLEI role credential  
> * Holder of an accepted ACDC credential chained to an accepted vLEI role credential  
> * Holder of an accepted ACDC credential chained to an accepted vLEI legal entity credential  
> * A KERI delegated identifier, delegated from any of the above.

## **5\. Overview of Client Authentication**

Client authentication is performed by presenting a **client assertion** in the token request. The assertion is:

> * A **CESR-encoded IPEX Grant message**  
> * Presenting one or more **vLEI or vLEI-chained ACDC credentials**  
> * Signed by the **current signing private key(s)** associated with the KERI identifier referenced as the presenter of the IPEX grant.

The IPEX Grant message serves the same purpose as the signed JWT in UDAP JWT Client Authentication:

> * It cryptographically binds the request to the client  
> * It proves possession of the client’s private key  
> * It conveys identity and authority claims required by the Authorization Server

## **6\. Token Endpoint Request**

### **6.1 General Requirements**

When using this profile:

> * The client **MUST NOT** use HTTP Basic authentication  
> * The client **MUST** authenticate using client_assertion_type and client_assertion  
> * All other OAuth parameters are unchanged from standard OAuth 2.0 and UDAP.

### **6.2 Authorization Code Flow Token Request**

The client authenticates to the token endpoint by including the following parameters:

```
POST /token  
Host: as.example.com  
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&  
code=AUTHORIZATION_CODE&  
redirect_uri=https://client.example.org/callback&  
client_id=CLIENT_ID&  
client_assertion_type=urn:ietf:params:oauth:client-assertion-type:acdc-vlei&  
client_assertion=-VA0s[... remainder of CESR encoded IPEX grant message omitted for brevity...]
```

### **6.3 Client Credentials Flow Token Request**

```
POST /token  
Host: as.example.com  
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&  
client_id=CLIENT_ID&  
client_assertion_type=urn:ietf:params:oauth:client-assertion-type:acdc-vlei&  
client_assertion=-VA0s[... remainder of CESR encoded IPEX grant message omitted for brevity...]
```

## **7\. Client Assertion Definition (Normative)**

### **7.1 client_assertion**

The client_assertion parameter SHALL contain a **CESR-encoded IPEX Grant message**.

The IPEX Grant message MUST:

> 1. Be encoded using **CESR** as defined by the CESR specification.  
> 2. Convey one or more **ACDC credentials** that:  
   * Are part of the vLEI credential family, and  
   * Chain to trust anchors recognized by the Authorization Server.  
> 3. Reference a KERI identifier controlled by the client.  
> 4. Be cryptographically signed using the private key corresponding to that identifier.

The IPEX Grant message MAY:

> 1. Contain the **key event log** belonging to the presenter of the IPEX grant message  
> 2. Contain the **key event log** belonging to the holder of the credential  
> 3. Contain the **key event log** belonging to the issuer of the credentials  
> 4. Contain **CESR** artifacts required to resolve any of the credentials (TELs, schema, etc.)

### **7.2 Required Semantics of the IPEX Grant**

The IPEX Grant message MUST reference a vLEI or credential chained to a vLEI that asserts, either directly or via chained credentials:  
*Note:*This section is incomplete and requires further development.

| Semantic Requirement | Description   |
| :---- | :---- |
| Client Identity | Identifies the legal entity represented by the client (e.g., LEI) |
| Client Identifier Binding | Binds the assertion to the OAuth client_id |
| Audience | Identifies the Authorization Server token endpoint |
| Issuance Time | Provides freshness information |
| Nonce / Replay Protection | Prevents replay within the allowed window |
| Grant Context | Conveys the purpose of the grant (OAuth client authentication) |

*Note:* These semantics mirror the required JWT claims (iss, sub, aud, exp, iat, jti) defined in UDAP JWT Client Authentication, but are expressed through ACDC and IPEX constructs rather than JWT claims.

## **8\. Authorization Server Validation**

Upon receiving a token request using this profile, the Authorization Server MUST:

> 1. Verify the client_assertion_type is supported.  
> 2. Parse the client_assertion as a CESR-encoded IPEX Grant message.  
> 3. Validate the IPEX message signature.  
> 4. Validate all enclosed ACDC credentials, including:  
   * Schema validity  
   * Chain integrity  
   * Issuer authorization  
   * Trust anchor policy  
> 5. Validate freshness and replay protections.  
> 6. Confirm the asserted client identity is authorized to act as the registered client_id.  
> 7. Validate all other OAuth parameters per the selected grant type.

Failure at any step MUST result in an invalid_client error.

## **9\. Security Considerations**

This profile provides security properties equivalent to UDAP JWT Client Authentication, including:

> * Strong client authentication using asymmetric cryptography  
> * Explicit proof-of-possession  
> * Audience restriction  
> * Replay protection  
> * Verifiable organizational identity via vLEI.

## **10\. Client Authentication without Pre-registration**

### **10.1 Credential Issue to Unregistered Client**

When the identity and privileges of a Client App can be fully determined by an Authorization Server based solely on the attributes listed in the client vLEI credential reference in the IPEX grant, the Authorization Server MAY allow an unregistered Client App to use this authentication protocol to get an access token using the client_credentials grant flow. In this case, as no client_id exists for the unregistered Client App, the corresponding trust community MUST define the set of credential attributes that an AS can use to uniquely identify a Client App, and specify a reserved value for the sub claim (e.g. “unregistered”) that can be included in the IPEX grant to signal to the AS that the subject of the IPEX grant is the unregistered Client App identified by the referenced vLEI credential. This specification does not restrict how the Authorization Server and/or Resource Server communicate to the Client App that this alternate workflow can be used.  
*Note:* that this approach is **not** suitable for applications utilizing the authorization code flow as there is no mechanism to preregister the Client App’s redirection URI; such unregistered clients SHOULD use the UDAP Dynamic Client Registration Protocol instead.

## **11\. IANA Considerations (Draft)**

This document registers a new OAuth client assertion type:

urn:ietf:params:oauth:client-assertion-type:acdc-vlei

---

© 2025 UDAP.org (style-matched draft export)