curl -X POST http://10.114.26.27/easw-127/createItem?name=test2 --write-out %{http_code} -H "Content-Type: application/xml" -u SVC-easwAP:ZNhAoWv52ZLl91UPxSfh -d @"$HOME/artifacts/jenkins/jobs/sample-ep-pipeline.xml"