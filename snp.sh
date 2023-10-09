repo_name=demo
image_tag=SAMPLE-PROJECT-${BUILD_NUMBER}
arn=arn:aws:sns:us-east-1:656705438072:demo-sq

critical_vulnr=$(aws ecr describe-image-scan-findings --repository-name $repo_name --image-id imageTag=$image_tag | grep -i "findingSeverityCounts" -A 5 | grep -i critical | cut -d ":" -f 2 | tr -d ",")
high_vulnr=$(aws ecr describe-image-scan-findings --repository-name $repo_name --image-id imageTag=$image_tag | grep -i "findingSeverityCounts" -A 5 | grep -i high | cut -d ":" -f 2 | tr -d ",")

if [ -z "$critical_vulnr" ]; then
    critical_vulnr=0
fi

if [ -z "$high_vulnr" ]; then
    high_vulnr=0
fi

echo "High vulnerabilities: $high_vulnr"
echo "Critical vulnerabilities: $critical_vulnr"

if[ "$high_critical_vulnerabilities" -gt "5"] then
    echo "High or critical vulnerabilities found ($high_critical_vulnerabilities) in the image. Build failed."

if [[ $high_vulnr -gt 0 || $critical_vulnr -gt 10 ]]
then
    echo "Your image has high vulnerabilities" && aws sns publish --topic-arn $arn --message "Image vulnerabilities: High vulnerabilities detected for image $image_tag in repository $repo_name" --subject "Image Vulnerability Alert"
    exit 1
else
    echo "Your image has low vulnerabilities"
fi
