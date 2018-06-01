#!/usr/bin/perl
package ConectDB;

use strict;
use warnings;
use v5.18.2;
use DBI;																			#módulo para conexión con bases de datos
use POSIX qw/ strftime /;															#módulo para fechas

my $dbname	= 'miGenomes';
my $dbhost	= '138.4.138.34';
my $dbuser	= 'userCBGP';
my $dbpwd	= 'contraseñaOBJ285';

################################################################################
#FUNCIÓN	que realiza la conexión a la Base de Datos
################################################################################
sub connect {
	return DBI->connect("DBI:mysql:$dbname;host=$dbhost", $dbuser, $dbpwd);
}

################################################################################
#FUNCIÓN	que devuelve un array con los nombres de los atributos de una tabla
#			recibida como parámetro
################################################################################
sub column_names {
	my ($dbh,$table) = @_;
	my $sth = ConectDB::select($dbh,"SELECT * FROM $table");
	$sth->execute();
  	my $fieldsref = $sth->{NAME};
  	my @fields = @{$fieldsref};
  	return @fields;
}

################################################################################
#FUNCIÓN	que obtiene la fecha de inserción en la BD de una fila, dada una
#			tabla y la clave principal.
################################################################################
sub date {
	my ($dbh,$table,$key) = @_;
	
	my @fields = column_names($dbh,$table);
	my $sth = ConectDB::select($dbh,"SELECT last_update FROM $table WHERE $fields[0] = ".$dbh->quote($key));
	$sth->execute();
	
	if (my $ref = $sth->fetchrow_arrayref) {
		return $$ref[0];
	}
}

################################################################################
#FUNCIÓN	que realiza una consulta de selección sobre la base de dataos
################################################################################
sub select {
	my ($dbh,$query) = @_;
	my $sth = $dbh->prepare($query);
	return $sth;
}

################################################################################
#FUNCIÓN	que realiza una consulta de borrado sobre la base de datos
################################################################################
sub delete {
	my ($dbh,$table,$id) = @_;
	my @fields = column_names($dbh,$table);
	my $query = "DELETE FROM $table WHERE $fields[0] = ".$dbh->quote($id).";";
	$dbh->do($query);																#ejecuta la consulta de borrado
}

################################################################################
#FUNCIÓN	que añade campos a una tabla de la base de datos
################################################################################
sub alter_table {
	my ($dbh,$table,$name,$type) = @_;
	$type = "VARCHAR(50)" if (not defined $type); 									#pone VARCHAR(50) por defecto
	my $query = "ALTER TABLE $table ADD '$name' $type";
	$dbh->do($query);																#ejecuta la consulta
}

################################################################################
#FUNCIÓN	que añade actualiza los valores de una tabla
################################################################################
sub update {
	my ($dbh,$table,$values_ref,$key) = @_;
	my @fields = column_names($dbh,$table);
	my %values = %{$values_ref};
	$values{"last_update"} = Interface::date();
	
	my $query = "UPDATE $table SET";
		foreach my $field (keys %values) {
			$query .= " $field = ".$dbh->quote($values{$field}).",";
		}
		chop $query;																#quita la coma del final
		$query .= " WHERE $fields[0] = ".$dbh->quote($key).";";
		$dbh->do($query);
}

################################################################################
#FUNCIÓN	que realiza una consulta de inserción sobre la base de datos
################################################################################
sub insert {
	my ($dbh,$table,$values_ref) = @_;
	my %values = %{$values_ref};
	$values{"last_update"} = Interface::date();

	## Crea la consulta de inserción
	my $query1 = "INSERT INTO $table (";
	my $query2 .= ") VALUES (";
	foreach my $field (keys %values) {			
		$query1 .= "$field,";
		$query2 .= $dbh->quote($values{$field}).",";
	}
	chop $query1; chop $query2; $query2 .= ")";									#quita la última coma		
	my $query = $query1.$query2;
	
	## Ejecuta la consulta de insercción
	my $num = $dbh->do($query);	
													
	if (not defined $num) {
		say "ERROR: No se ha podido realizar la insercion";
	}
}

################################################################################
#FUNCIÓN	que imprime los resultados de una consulta de selección en formato
#			tabla
################################################################################
sub print_table {
	my ($sth) = @_;
	$sth->execute();
	my $names = $sth->{NAME};
	my $numFields = $sth->{'NUM_OF_FIELDS'} - 1;
	for my $i ( 0..$numFields ) {
		printf("%s%s", " | ", $$names[$i]);
	}
	print " |\n";
	while (my $ref = $sth->fetchrow_arrayref) {
		for my $i ( 0..$numFields ) {
			if (defined $$ref[$i]) {
				printf("%s%-30s", " | ", $$ref[$i]);
			}
			else {
				print " | ";
			}
		}
	print " |\n";
	}
	$sth->finish();
}

################################################################################
#FUNCIÓN	que imprime los resultados de una consulta de selección en formato
#			formulario
################################################################################
sub print_form {
	my ($sth,$display) = @_;
	$sth->execute();
	my $names = $sth->{NAME};
	my $numFields = $sth->{'NUM_OF_FIELDS'} - 1;
	while (my $ref = $sth->fetchrow_arrayref) {
		for my $i (0..$numFields) {
			if (defined $$ref[$i]) {
				printf("%s: %s\n", $$names[$i], $$ref[$i]);
			}
		}
		print "\n";
	}
	$sth->finish();
}

################################################################################
#FUNCIÓN	que realiza la desconexión de la Base de Datos
################################################################################
sub disconnect {
	my ($dbh) = @_;
	if (! $dbh->disconnect) {
    	say "Error al desconectarse de la base de datos";
	}
}

################################################################################
#FUNCIÓN	que realiza una inserción de datos en la tabla especificada de la BD
#			y en el caso de que la clave principal ya exista, realiza un update.
################################################################################
sub upsert {
	my ($dbh,$table,$values_ref) = @_;
	my %values = %{$values_ref};
	my @fields = column_names($dbh,$table);
	my @data;
	
	## Prepara el array de datos
	foreach my $key (keys %values) {
		$values{$key}{"last_update"} = Interface::date();
		
		my (@rowInsert,@rowUpdate);
		foreach my $i (0..$#fields) {
			push @rowInsert,$values{$key}{$fields[$i]};
			push @rowUpdate,$values{$key}{$fields[$i]};
		}
		push @rowInsert,@rowUpdate;													#junta en un solo array los valores del insert y del update
		push @data,\@rowInsert;
	}
	
	## Prepara la consulta SQL
	my $val = ""; my $update = "";
	foreach my $i (0..$#fields) {
		$val .= "?,";
		$update .= "$fields[$i]=?,";
	}
	chop $val; chop $update;														#quita la última coma de los valores del insert y del update
	my $sth = $dbh->prepare("INSERT INTO $table VALUES ($val) ON DUPLICATE KEY UPDATE $update");
	
	## Ejecuta la consulta SQL
	$dbh->begin_work();		#$dbh->do("BEGIN"); #$dbh->do("START TRANSACTION");
	foreach my $row (@data)
	{
	   $sth->execute(@$row);
	}
	$dbh->commit();		#$dbh->do("COMMIT");
}

################################################################################
#FUNCIÓN	que comprueba en una tabla si existe una fila con un determinado
#			identificador. Si existe devuelve un 1 y si no existe devuelve un 0.
################################################################################
sub exists {
	my ($table,$id) = @_;
	my $result = 0;
	my $dbh = ConectDB::connect();													#realiza la conexión a la BD
	my $query = "SELECT * FROM $table WHERE ".ConectDB::primary_key($dbh,$table)." = '$id'";
	my $sth = ConectDB::select($dbh,$query);
	$sth->execute();
	while (my $ref = $sth->fetchrow_arrayref) {
		$result = 1;
	}
	ConectDB::disconnect($dbh);														#desconecta de la BD
	return $result;
}

################################################################################
#FUNCIÓN	que devuelve la clave primaria de una tabla recibida como parámetro.
################################################################################
sub primary_key{
	my ($dbh,$table) = @_;
	my $sth = ConectDB::select($dbh,"SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = '$dbname' AND TABLE_NAME = '$table' AND COLUMN_KEY IN('PRI')");
	$sth->execute();
	my $ref = $sth->fetchrow_arrayref;
	return $$ref[0];
}

1;
