// benchmark code for multiple classes, multiple methods
(
  ~allClasses = Class.allClasses;
  ~classes = ~allClasses.select { |x|
    x.asString.beginsWith( "HugeTestClass" )
  };

  ~times = 5.collect {

    bench {
      200000.do { |i|
        var class;
        var method;

        class = ~classes.choose;
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
