#!/bin/sh

mem_file=test_mem.txt
spd_file=test_speed.txt
sc_output_file=sc_output.txt
sclang_app=/Applications/SuperCollider.app/Contents/MacOS/sclang 


max_method_power=16     # orig value: 16
max_class_power=12      # orig value: 12
max_methodclass_power=8 # orig value: 8
max_array_power=24      # orig value: 20

#############################
# FUNCTIONS
#############################

# arg: string to write in both
write_to_output_files () {
  echo "\n$1" >>$spd_file
  echo "\n$1" >>$mem_file
}

# arg: string for first column
write_column_headers () {
  echo "\n$1 Min_time Mean_time Max_time" >>$spd_file
  echo "\n$1 Memory_used" >>$mem_file
}

# arg: what to print for first column
prep_benchmark_files () { printf "$1 " >>$mem_file; printf "$1 " >>$spd_file; }

# arg: what file to run
run_supercollider () {
  printf "Opening SuperCollider..."
  $sclang_app $1 >$sc_output_file
  echo Done
}

cleanup () { 
  # echo "Done with $n\nDeleting $filename"; 
  rm $filename; 
}

# args: $1 = num classes, $2 = num methods per class
construct_class_file () {
  filename=HugeTestClassFile.sc
  echo "// test file" >$filename
  for i in $(seq 1 $1)
  do
    echo "HugeTestClass$i {" >>$filename
    for j in $(seq 1 $2)
    do
      echo "hugeTestClassMethod$j { ^$i + $j }" >>$filename
    done
    echo "}" >>$filename
  done
}

# arg: array size, max rand index
construct_array_file () {
  filename=HugeArrayTestFile.scd
  echo "// test file" >$filename
  cat ./benchmark_array.scd | sed "s/__size__/~array_size = $1;/g" | sed "s/__index__/~max_rand_index = $2;/g" >>$filename
}

# args: num methods, num classes, file to run
benchmark_classes_and_methods () {
  construct_class_file $1 $2
  prep_benchmark_files $(( $1 > $2 ? $1 : $2 ))
  run_supercollider $3
  cleanup
}

# args: array length, max range for access index, file to run
benchmark_array () {
  construct_array_file $1 $2
  prep_benchmark_files $1
  run_supercollider $filename
  cleanup
}

#############################
# SCRIPT
#############################

echo "Begin script\nSuperCollider output written to $sc_output_file\n"

# delete existing files
rm $mem_file
rm $spd_file

##################################
# SINGLE CLASS approach
##################################
echo Testing effect of one class, many methods

bm_sclass_mmethod () {
  write_column_headers "Methods"
  for n in $(seq 1 $max_method_power) 
  do
    n=$(echo 2^$n | bc)
    echo Testing $n methods on one class.
    benchmark_classes_and_methods 1 $n $1
  done
}

write_to_output_files "One class, many methods: random access"
bm_sclass_mmethod ./benchmark_singleclass.scd
write_to_output_files "One class, many methods: ordinary methods"
bm_sclass_mmethod ./benchmark_normal_ops.scd

##################################
# MULTICLASS section 
##################################
echo Testing effect of many classes, one method each

bm_mclass_smethod () {
  write_column_headers "Classes"
  for n in $(seq 1 $max_class_power)
  do
    n=$(echo 2^$n | bc)
    echo Testing $n classes with one method each.
    benchmark_classes_and_methods $n 1 $1
  done
}

write_to_output_files "Many classes, one method: random access"
bm_mclass_smethod ./benchmark_multiclass.scd
write_to_output_files "Many classes, one method: ordinary methods"
bm_mclass_smethod ./benchmark_normal_ops.scd

##################################
# MULTIMETHOD & MULTICLASS section 
##################################
echo Testing effect of many classes, many methods each

bm_mclass_mmethod () {
  write_column_headers "Classes_and_methods"
  for n in $(seq 1 $max_methodclass_power)
  do
    n=$(echo 2^$n | bc)
    echo Testing $n classes with $n methods each.
    benchmark_classes_and_methods $n $n $1
  done
}

write_to_output_files "Many classes, many methods: random access"
bm_mclass_mmethod ./benchmark_multiclass.scd
write_to_output_files "Many classes, many methods: ordinary methods"
bm_mclass_mmethod ./benchmark_normal_ops.scd

##################################
# ARRAY section 
##################################
echo Testing effect of large arrays, one access index

# write headers
write_to_output_files "Array accesses, repeatedly accessing index 0"
write_column_headers "Array_size"

for n in $(seq 1 $max_array_power)
do
  n=$(echo 2^$n | bc)
  echo Testing floating-point array of size $n.
  benchmark_array $n 1 ./benchmark_array.scd
done

##################################
# ARRAY section 
##################################
echo Testing effect of large arrays, random access index

# write headers
write_to_output_files "Array accesses, random accesses"
write_column_headers "Array_size_random"

for n in $(seq 1 $max_array_power)
do
  n=$(echo 2^$n | bc)
  echo Testing floating-point array of size $n.
  benchmark_array $n $n ./benchmark_array.scd
done


echo \\\nAll Done\\\n
