# -*- coding: utf-8 -*-
 #!/usr/bin/env ruby

#
# Author: José Emiliano Cabrera Blancas (jemiliano.cabrera@gmail.com)
#

# Acciones permitidas:
#
#    compile: Compila para su uso con ruby-processing
#    compile_c: Compila para poder usar y probar tus funciones en ./main
#    test: Ejecuta las pruebas(si no esta compilado, seguramente truena esta accion)
#    clean: Borra todos los archivos que se generaron en la instalación

# Variables generales para compile y compile_c
@cc = "gcc"
# Aqui debes agregar los demás objectos que programes ejemplo : [ ..., "algorithms/heap.o"  ,...]
@objs = ["points/2d_points.o","double_linked_list/double_linked_list.o", "convex_hull/convex_hull.o"]
@cflags = "-I."
@debug = "-g"
@main = "main.o"

#Variables de compile
# Aqui debes agregar los objectos que programes ejemplo: [ ..., "algoruthms/heap.so", ...]
@shared = ["points/2d_points.so","double_linked_list/double_linked_list.so", "convex_hull/convex_hull.so"]
@lib_dir = "lib/"

args = ARGV.clone
actions = ["compile","compile_c", "test", "clean"]
if (not(args.any?) or args.keep_if{|x| not(actions.include?(x))}.any?) then
  puts "Actions avaliable:"
  puts actions.map{|x| "\t"+x}
  exit(0)
end

def compile_c
  puts "Compilando archivos fuentes:"
  objs = @objs + [@main]
  objs.each do |obj|
    command = "#{@cc} #{@debug} -c -o #{obj} #{obj[0..-2] + "c"} #{@cflags}"
    puts "\t"+ command
    exit (0) if not((system(command)))
  end
  command = "#{@cc} #{@debug} -o #{@main[0..-3]} #{objs.join(" ")} #{@cflags}"
  puts "\t"+ command
  puts "No compilo de forma correcta" if not(system(command))
end	

def compile
  puts "Compilando archivos fuentes:"
  @objs.each do |obj|
    command = "#{@cc} -c -o #{obj} #{obj[0..-2] + "c"} #{@cflags}"
    puts "\t"+ command
    exit (0) if not((system(command)))
  end
  
  puts "Convirtiendo a bibliotecas dinamicas"
  @shared.each do |obj|
    library = obj.split('/').last
    compiled_libraries = `ls #{@lib_dir}`.split(" ")
    
    libs = compiled_libraries.inject("") {
      |string,lib|
      string += "-l#{lib[3...-3]} "
    }
    
    command = "#{@cc} -shared -o lib/lib#{library} #{obj[0..-3] + "o"}" +
              " -L#{@lib_dir} #{libs}"
    puts "\t" + command
    puts "No compilo de forma correcta" if not((system(command)))
  end
end

def test
  require File.expand_path(File.join(File.dirname(__FILE__), "tests/tests"))
  Test.run
end

def clean
  puts "Borramos los archivos *.o"
  
  command = "rm #{(@objs + [@main]).join(" ")}"
  puts "\t" + command
  system(command)

  puts "Borramos el ejecutable main"
  command = "rm #{@main[0..-3]}"
  puts "\t" + command
  system(command)

  puts "Borramos todos los archivos .so"
  
  command = "rm lib/*.so"
  puts "\t" + command
  system(command)
end


#
# Ejecutan todos los comandos que se le enviaron
#
ARGV.each do 
  |action|
  send(action)
end