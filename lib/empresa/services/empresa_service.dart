import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/empresa/repositories/empresa_repository.dart';

part 'empresa_service.g.dart';

class EmpresaService {
  final EmpresaRepository empresaRepository;

  EmpresaService({required this.empresaRepository});

  Future<Empresa?> obterEmpresaPorId(String id) async {
    return await empresaRepository.obterEmpresaPorId(id);
  }

  Future<List<Empresa>> getEmpresas() async {
    return await empresaRepository.getEmpresas().first;
  }

  Future<Empresa> criarEmpresa(Empresa empresa) async {
    return await empresaRepository.inserirEmpresa(empresa);
  }

  Future<void> atualizarEmpresa(Empresa empresa) async {
    await empresaRepository.atualizarEmpresa(empresa);
  }

  Future<void> deletarEmpresa(String id) async {
    await empresaRepository.deletarEmpresa(id);
  }

  Future<Empresa?> obterEmpresaPorUsuarioId(String usuarioId) async {
    return await empresaRepository.obterEmpresaPorUsuarioId(usuarioId);
  }

  Future<Set<Empresa>> obterListaEmpresasPorCategoriaDoProduto(
      String categoriaId) async {
    return await empresaRepository
        .obterListaEmpresasPorCategoriaDoProduto(categoriaId);
  }
}

@Riverpod(keepAlive: true)
EmpresaService empresaService(Ref ref) {
  final repository = ref.watch(empresaRepositoryProvider);
  return EmpresaService(empresaRepository: repository);
}
