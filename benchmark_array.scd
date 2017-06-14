// benchmark test for big array
(
  __size__  // replaced with ~array_size = X;
  __index__ // replaced with ~max_rand_index = X;
  ~array = Array.fill( ~array_size, { 100.0.rand } );

  ~times = 5.collect {
    bench {
      1e6.do { |i|
        var index;
        var value;

        index = ~max_rand_index.rand;
        value = ~array[ index ];
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
