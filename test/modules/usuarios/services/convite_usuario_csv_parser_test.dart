import 'package:flutter_test/flutter_test.dart';
import 'package:geduc_rae_mobile/modules/usuarios/services/convite_usuario_csv_parser.dart';

void main() {
  group('ConviteUsuarioCsvParser', () {
    test('importa ponto e vírgula, normaliza e-mail e perfil', () {
      final itens = ConviteUsuarioCsvParser.parse('''
nome;email;telefone;cargo;setor;perfilAcesso
Maria Silva; MARIA@GEDUC.COM.BR ;85999990000;Agente de Trânsito;GEDUC;Agente
''');

      expect(itens, hasLength(1));
      expect(itens.single.nome, 'Maria Silva');
      expect(itens.single.email, 'maria@geduc.com.br');
      expect(itens.single.perfilAcesso, 'agente');
    });

    test('aceita campos entre aspas e separador vírgula', () {
      final itens = ConviteUsuarioCsvParser.parse('''
nome,email,telefone,cargo,setor,perfilAcesso
"Lima, Cláudio",lima@geduc.com.br,,"Agente, Trânsito",GEDUC,coordenador
''');

      expect(itens.single.nome, 'Lima, Cláudio');
      expect(itens.single.cargo, 'Agente, Trânsito');
    });

    test('recusa perfil privilegiado e e-mail duplicado', () {
      expect(
        () => ConviteUsuarioCsvParser.parse('''
nome;email;telefone;cargo;setor;perfilAcesso
Admin;admin@geduc.com.br;;;GEDUC;administrador
'''),
        throwsFormatException,
      );
      expect(
        () => ConviteUsuarioCsvParser.parse('''
nome;email;telefone;cargo;setor;perfilAcesso
Um;mesmo@geduc.com.br;;;GEDUC;agente
Dois;MESMO@GEDUC.COM.BR;;;GEDUC;agente
'''),
        throwsFormatException,
      );
    });
  });
}
