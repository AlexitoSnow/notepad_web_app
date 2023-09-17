class Archivo {
  String nombre;
  String contenido;
  Archivo(this.nombre, this.contenido);
  @override
  bool operator ==(Object other) {
    if (other is Archivo) {
      return nombre == other.nombre;
    }
    return false;
  }

  @override
  int get hashCode => nombre.hashCode;
}
