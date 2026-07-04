class CoordenadorModel {
  final String id, nome, email, telefone, setor;
  final int agentesPadrao, terceirizadosPadrao;
  final bool ativo;
  const CoordenadorModel({required this.id, required this.nome, required this.email, required this.telefone, required this.setor, required this.agentesPadrao, required this.terceirizadosPadrao, required this.ativo});
  factory CoordenadorModel.fromMap(Map<String,dynamic> map)=>CoordenadorModel(id:map['id']??'',nome:map['nome']??'',email:map['email']??'',telefone:map['telefone']??'',setor:map['setor']??'',agentesPadrao:map['agentesPadrao']??0,terceirizadosPadrao:map['terceirizadosPadrao']??0,ativo:map['ativo']??true);
  Map<String,dynamic> toMap()=>{'id':id,'nome':nome,'email':email,'telefone':telefone,'setor':setor,'agentesPadrao':agentesPadrao,'terceirizadosPadrao':terceirizadosPadrao,'ativo':ativo};
}
