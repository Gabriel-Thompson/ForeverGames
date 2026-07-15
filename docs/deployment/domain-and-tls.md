# Domain and TLS

The canonical origin is `https://myforevergames.com`; `www` redirects to apex. Validate the Container Apps custom domain using Azure's TXT value, bind an Azure-managed certificate, and verify renewal. Then enable `configureDns` and supply the existing zone resource group.

Expected records are apex and `www` aliases to Container Apps plus `asuid` TXT. If the provider forbids apex CNAME, use ALIAS/ANAME or manage apex outside Bicep. Confirm HTTPS, redirect, HSTS, certificate chain, and health endpoints before traffic.
