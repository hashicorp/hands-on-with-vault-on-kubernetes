0-install-vault:
	bash scripts/00-install-vault.sh

0-build-cluster:
	bash scripts/00-build-cluster.sh

1-consul:
	bash scripts/01-consul.sh
	
2-certs:
	bash scripts/02-certs.sh
	
3-vault:
	bash scripts/03-vault.sh
	
4-acl:
	bash scripts/04-acl.sh

5-auth:
	bash scripts/05-k8s-auth.sh

6-policy:
	bash scripts/06-policy.sh

7-simple:
	bash scripts/07-exampleapp-simple.sh

8-token:
	bash scripts/08-token.sh

9-secret:
	bash scripts/09-get-secret.sh

10-sidecar:
	bash scripts/10-exampleapp-sidecar.sh

11-mysql:
	bash scripts/11-deploy-mysql.sh

12-database-secret-engine:
	bash scripts/12-dynamic-db-secret.sh

clean-kubernetes:
	bash scripts/clean-kubernetes.sh

clean:
	bash scripts/clean-all.sh