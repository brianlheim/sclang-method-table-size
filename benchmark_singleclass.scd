// benchmark code for one class
(
  ~times = 5.collect {
    bench {
      200000.do { |i|
        var className = "HugeTestClass1";
        var class;
        var method;

        class = className.asSymbol.asClass;
        method = class.methods.choose;

        class.new.perform( method.name );
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

