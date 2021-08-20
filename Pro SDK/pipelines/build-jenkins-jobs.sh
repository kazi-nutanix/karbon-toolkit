result=$(curl -X POST http://10.114.26.27/easw-127/job/$1/build --write-out %{http_code} -u SVC-easwAP:ZNhAoWv52ZLl91UPxSfh)
echo "Builds scheduled with code $result"
