# gitops-helm
 find ./base -name '*' | xargs wc -l^C
 helm template base/ -f global-values.yml | wc -l