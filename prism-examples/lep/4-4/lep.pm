// synchronous leader election protocol  (itai & Rodeh)
// dxp/gxn 25/01/01
// N=4 and K=4

probabilistic

// number of processes a processes needs to read
// N-1 (do not need to read yourself)
const N=3;

// counter module used to count the number of processes that have been read
// and to know when a process has decided
module counter

	// counter (c=i  means process j reading process (i-1)+j next)
	c : [1..N];

	//increase counter
	[read] (c<N) -> (c'=c+1);
	// finished reading
	[read] (c=N) -> (c'=c);
	//decide
	[done] (u1 | u2 | u3 | u4) -> (c'=c);
	// pick again reset counter
	[retry] !(u1 | u2 | u3 | u4) -> (c'=1);
	// loop (when finished to avoid deadlocks)
	[loop] (s1=3) -> (c'=c);

endmodule

module process1

	// local state
	s1 : [0..3];
	// s1=0 make random choice
	// s1=1 reading
	// s1=2 deciding
	// s1=3 finished

	// has a unique id so far (initially true)
	u1 : bool;

	// value to be sent to next process in the ring (initially sets this to its own value)
	v1 : [0..3];

	// random choice
	p1 : [0..3];

	// pick value
	[pick] (s1=0) -> 0.25 : (s1'=1) & (p1'=0) & (v1'=0) & (u1'=true)
		       + 0.25 : (s1'=1) & (p1'=1) & (v1'=1) & (u1'=true)
		       + 0.25 : (s1'=1) & (p1'=2) & (v1'=2) & (u1'=true)
		       + 0.25 : (s1'=1) & (p1'=3) & (v1'=3) & (u1'=true);
	// read
	[read] (s1=1) & (u1) & !(p1=v2) & (c<N) -> (u1'=true) & (v1'=v2);
	[read] (s1=1) & (u1) &  (p1=v2) & (c<N) -> (u1'=false) & (v1'=v2) & (p1'=0);
	[read] (s1=1) & (!u1) & (c<N) -> (u1'=false) & (v1'=v2);
	// read and move to decide
	[read] (s1=1) & (u1) & !(p1=v2) & (c=N) -> (s1'=2) & (u1'=true) & (v1'=0) & (p1'=0);
	[read] (s1=1) & (u1) &  (p1=v2) & (c=N) -> (s1'=2) & (u1'=false) & (v1'=0) & (p1'=0);
	[read] (s1=1) & (!u1) & (c=N) -> (s1'=2) & (u1'=false) & (v1'=0);
	// deciding
	[done] (s1=2) -> (s1'=3) & (u1'=false) & (v1'=0) & (p1'=0);
	[retry] (s1=2) -> (s1'=0) & (u1'=false) & (v1'=0) & (p1'=0);
	// loop (when finished to avoid deadlocks)
	[loop] (s1=3) -> (s1'=3);

endmodule

// construct remaining processes through renaming
module process2=process1[s1=s2,p1=p2,v1=v2,u1=u2,v2=v3] endmodule
module process3=process1[s1=s3,p1=p3,v1=v3,u1=u3,v2=v4] endmodule
module process4=process1[s1=s4,p1=p4,v1=v4,u1=u4,v2=v1] endmodule

label "leader_elected" = (s1=3) & (s2=3) & (s3=3) & (s4=3);
    
