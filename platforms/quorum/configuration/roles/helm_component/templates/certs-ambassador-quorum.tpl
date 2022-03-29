apiVersion: helm.fluxcd.io/v1
kind: HelmRelease
metadata:
  name: {{ component_name }}
  namespace: {{ component_ns }}
  annotations:
    fluxcd.io/automated: "false"
spec:
  releaseName: {{ component_name }}
  chart:
    git: {{ org.gitops.git_url }}
    ref: {{ org.gitops.branch }}
    path: {{ charts_dir }}/certs-ambassador-quorum
  values:
    opensslVars:
      domain_name: "{{ peer.name }}.{{ external_url }}"
      domain_name_api: "{{ peer.name }}api.{{ external_url }}"
      domain_name_web: "{{ peer.name }}web.{{ external_url }}"
      domain_name_tessera: "{{ peer.name }}-tessera.{{ component_ns }}"
    vars:
     ambassadortls: "{{playbook_dir}}/build/{{component_name}}/{{node_name}}"
     rootca: "{{playbook_dir}}/build/quorumrootca" 
     kubernetes: "{{ item.k8s }}"
     node_name: "{{ peer.name }}"
    peer:
      name: {{ peer.name }}
      gethPassphrase: {{ peer.geth_passphrase }}
    

    metadata:
      name: {{ component_name }}
      namespace: {{ component_ns }}
      external_url: {{ name }}.{{ external_url }}
    image:
      initContainerName: {{ network.docker.url }}/alpine-utils:1.0
      node: quorumengineering/quorum:{{ network.version }}
      pullPolicy: Always
    acceptLicense: YES
    vault:
      address: {{ vault.url }}
      role: vault-role
      authpath: quorum{{ org_name }}
      serviceaccountname: vault-auth
      certsecretprefix: {{ vault.secret_path | default('secretsv2') }}/data/{{ org.name | lower }}-quo
      retries: 30
    healthCheckNodePort: 0
    sleepTimeAfterError: 60
    sleepTime: 10
    healthcheck:
      readinesscheckinterval: 10
      readinessthreshold: 1

