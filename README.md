# distributed_load_testing_jmeter_ecs

This setup assumes that you are running EC2 instance on rpm systems like Amazon linux 2.

1. Download zipped file to a folder. 
2. Unzip the folder and place your .pem file to connect to your ec2 instance in the unzipped folder.
3. update run.properties file with details.
4. Run ```chmod 777 runJmeterTests.sh```
5. run ```./runJmeterTests.sh```
