command="ls"
for i in {1..100}
do
    num=$i
    d=10
    if (( $i < $d ))
    then
    num="0$i"
    fi
    dm="root@server$num.com"
	echo $dm
    ssh   -t $dm $command
    
    

done

