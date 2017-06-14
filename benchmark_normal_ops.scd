// benchmark code for misc methods
(
  ~times = 5.collect {
    bench {
      20000.do { |i|
        var x, y, z;

        x = i.rand;
        y = x.rand + i.rand;
        z = [ 3, 4, 5, 6 ].squared;
        z = z * y + x;

        z.collect( _.asString ).reduce( '++' );
      };
    };
  };

  ~times = [ ~times.minItem, ~times.mean, ~times.maxItem].round( 0.001 );
  ~times = ~times.collect( _.asString );
  ~times = ~times.collect( _.padRight(5, "0") );
  ~times = ~times.join( " " );
  unixCmdGetStdOut( "echo" + ~times + ">>test_speed.txt" );
  unixCmdGetStdOut( "top -l 1 | grep sclang | sed -E \"s/^([^ ]+ +){7}([^ ]+).*/\\2/g\" >>test_mem.txt" );
  0.exit();
)

