BEGIN{
	sim_end = 200;
	i=0;
	while (i<=sim_end) {sec[i]=0; i+=1;};
}

{
	if ($1=="D" && $7=="cbr" && $3=="_0_") {
		sec[int($2)]+=$8;
	};
}

END{	
	i=0;
	while (i<=sim_end) {print i " " sec[i]*8; i+=1;};
} 
