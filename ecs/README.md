# ECS
this script is designed to manage the ecs containers in AWS.  It is setup to allow easy changes without using the console.
It is justa wrapper for the aws-cli but it does make it easier to use (I think)



## Usage :
- ecs help			Displays this info
- ecs setup [env1]		run this to set ecs to talk to your cluster
-				(note - you need to copy, paste and run the line it gives you)
- ecs list			display pods running in the cluster
- ecs cluster			Gives info about the ECS cluster
- ecs service [name] 		Gives info about a service running inside that cluster
-				Example : ecs service nginx
- ecs resize name [size]		Change or display the number of each type of pod
-				Example : ecs resize repo-name 1      or just : ecs resize nginx
- ecs update name version	Update to new code version
-				Example : ecs update repo-name repo-name:v1.2.3
- ecs runbastion			Run the bastion server
- ecs logs bastion-sandbox	Return logs for the running service
- ecs join tasknum		Exec into that pod
-				Example : ecs join 1234567890123456789012
-





