import 'package:flutter/material.dart';

class TelaPrivacidade extends StatelessWidget {
  const TelaPrivacidade({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D9D9),
      appBar: AppBar(
        title: const Text(
          'Privacidade',
          style: TextStyle(
            fontWeight : FontWeight.bold,
            color: Color(0xFFD9D9D9), // Cor do título
          ),
        ),
        backgroundColor: const Color(0xFF011689),
        centerTitle: true,
        elevation: 4,
        iconTheme:
            const IconThemeData(color: Color(0xFFD9D9D9)), // Cor do ícone
      ),
      body: SingleChildScrollView(
        // Adicionando rolagem
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Adicionando margem externa
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Alinhando o conteúdo à esquerda
            children: [
              // Retângulo com texto
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9), // Fundo cinza
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Termos de Uso e Política de Privacidade', // Título em negrito
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8), // Espaço entre os textos
                    Text(
                      '''Bem-vindo ao aplicativo de Gestão de Extintores de Incêndio do Metro de SP. Este documento estabelece os termos e condições para o uso do aplicativo, bem como a política de privacidade referente ao tratamento de dados coletados.
1. Termos de Uso
1.1. Este aplicativo é exclusivo para uso interno de funcionários autorizados e tem como objetivo facilitar a gestão de extintores de incêndio e a manutenção da segurança.
1.2. Os usuários devem acessar o aplicativo apenas com suas credenciais individuais fornecidas pela empresa.
1.3. É proibido compartilhar informações acessadas por meio deste aplicativo com terceiros sem autorização prévia.
1.4. O uso indevido do aplicativo ou a violação destes termos poderá resultar em medidas administrativas ou legais.
2. Política de Privacidade
2.1. Coleta de Dados
O aplicativo pode coletar os seguintes dados:
• Informações de identificação do funcionário (nome, ID de usuário);
• Dados sobre os extintores (número de série, localização, data de inspeção, validade e demais informações).
2.2. Uso dos Dados
Os dados coletados serão usados exclusivamente para:
• Gerenciar e acompanhar as inspeções e manutenções dos extintores;
• Localização do equipamentos;
• Identificar responsabilidades em operações realizadas no aplicativo.
2.3. Armazenamento e Proteção de Dados
Os dados serão armazenados de forma segura em servidores protegidos, conforme as normas de segurança digital aplicáveis.
2.4. Compartilhamento de Dados
As informações coletadas não serão compartilhadas com terceiros, exceto quando exigido por lei ou com autorização expressa do funcionário.
2.5. Direitos do Usuário
Os usuários têm direito de:
• Solicitar acesso aos dados armazenados sobre si;
• Corrigir dados incorretos ou incompletos;
• Solicitar a exclusão de seus dados, salvo quando necessário para cumprimento de obrigações legais.
3. Aceitação
Ao usar este aplicativo, você concorda com os termos descritos acima. Caso não concorde, entre em contato com o administrador para mais informações.
                      ''',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                        height: 1.3, // Diminuindo o espaçamento entre as linhas
                      ),
                      textAlign: TextAlign.left, // Alinhando o texto à esquerda
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Logo opaca centralizada na parte inferior
              Center(
                child: Opacity(
                  opacity: 0.2,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width *
                        0.5, // 50% da largura
                    height: MediaQuery.of(context).size.height *
                        0.1, // 10% da altura
                    child: FittedBox(
                      fit: BoxFit.contain, // Ajusta a imagem sem distorção
                      child: Image.asset(
                        'assets/images/logo.jpeg', // Caminho da imagem
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}