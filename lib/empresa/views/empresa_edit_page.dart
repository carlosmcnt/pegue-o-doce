import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:pegue_o_doce/empresa/controllers/empresa_edit_controller.dart';
import 'package:pegue_o_doce/empresa/models/empresa.dart';
import 'package:pegue_o_doce/empresa/models/local_entrega.dart';
import 'package:pegue_o_doce/empresa/views/perfil_empresa.dart';
import 'package:pegue_o_doce/usuario/services/usuario_service.dart';
import 'package:pegue_o_doce/utils/widget_utils.dart';
import 'package:pegue_o_doce/utils/tema.dart';
import 'package:pegue_o_doce/utils/validador.dart';
import 'package:pegue_o_doce/utils/formatador.dart';

class EmpresaEditPage extends ConsumerStatefulWidget {
  final Empresa empresa;

  const EmpresaEditPage({super.key, required this.empresa});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return EmpresaEditPageState();
  }
}

class EmpresaEditPageState extends ConsumerState<EmpresaEditPage> {
  late TextEditingController _nomeFantasiaController;
  late TextEditingController _chavePixController;
  late TextEditingController _descricaoController;
  late TextEditingController _locaisEntregaController;
  late TextEditingController _quantidadeMinimaEncomendaController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late List<LocalEntrega> _locaisEntrega = [];
  final MapController _mapController = MapController();
  LatLng coordenadaInicial = const LatLng(-13.0027, -38.5070);
  double _zoom = 15;
  late String tipoChavePix = '';
  bool ignorarTipoChavePix = false;
  LatLng? coordenadas;
  bool mostrarMapa = false;

  Empresa get empresa => widget.empresa;

  @override
  void initState() {
    super.initState();
    _nomeFantasiaController = TextEditingController(text: empresa.nomeFantasia);
    _chavePixController = TextEditingController(text: empresa.chavePix);
    _descricaoController = TextEditingController(text: empresa.descricao);
    _quantidadeMinimaEncomendaController = TextEditingController(
        text: empresa.quantidadeMinimaEncomenda.toString());
    _locaisEntregaController = TextEditingController();
    _locaisEntrega = empresa.locaisEntrega;
    if (_nomeFantasiaController.text.isNotEmpty) {
      ignorarTipoChavePix = true;
    }
  }

  @override
  void dispose() {
    _nomeFantasiaController.dispose();
    _chavePixController.dispose();
    _descricaoController.dispose();
    _locaisEntregaController.dispose();
    super.dispose();
  }

  Future<void> editarEmpresa() async {
    final usuarioLogado =
        await ref.read(usuarioServiceProvider).obterUsuarioLogado();

    final empresaNova = empresa.copyWith(
      nomeFantasia: _nomeFantasiaController.text,
      chavePix: _chavePixController.text,
      quantidadeMinimaEncomenda:
          int.parse(_quantidadeMinimaEncomendaController.text),
      descricao: _descricaoController.text,
      locaisEntrega: _locaisEntrega,
      usuarioId: usuarioLogado.id,
    );

    await ref
        .read(empresaEditControllerProvider.notifier)
        .inserirOuAtualizarEmpresa(empresaNova);

    ref.invalidate(empresaEditControllerProvider);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PerfilEmpresaPage(
          empresa: empresaNova,
        ),
      ),
    );
  }

  void verificarLocalEntrega() {
    if (_locaisEntregaController.text.isEmpty) {
      WidgetUtils.showSnackbar(
          mensagem: 'Adicione um nome para o local de entrega',
          context: context,
          erro: true);
      return;
    }
    if (coordenadas == null) {
      WidgetUtils.showSnackbar(
          mensagem: 'Selecione o local no mapa', context: context, erro: true);
      return;
    }
    setState(() {
      _locaisEntrega.add(LocalEntrega(
        nome: _locaisEntregaController.text,
        coordenadas: coordenadas!,
      ));
      _locaisEntregaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Tema.padrao(
        '${empresa.id == null ? 'Cadastrar ' : 'Atualizar '} Empresa',
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const SizedBox(height: 10),
                TextFormField(
                  controller: _nomeFantasiaController,
                  maxLength: 40,
                  decoration: InputDecoration(
                    labelText: 'Nome Fantasia:',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(FontAwesomeIcons.building),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nome Fantasia é obrigatório';
                    }
                    return null;
                  },
                  inputFormatters: [
                    FormatadorLetrasMaiusculas(),
                  ],
                ),
                const SizedBox(height: 15),
                DropdownMenu<String>(
                  label: const Text('Tipo de chave PIX:'),
                  leadingIcon: const Icon(Icons.key),
                  dropdownMenuEntries: Validador().listaTiposChavesPix(),
                  width: MediaQuery.sizeOf(context).width,
                  initialSelection:
                      empresa.chavePix.isNotEmpty ? empresa.chavePix : '',
                  onSelected: (value) {
                    setState(() {
                      tipoChavePix = value!;
                      _chavePixController.clear();
                    });
                  },
                  requestFocusOnTap: false,
                  enableSearch: false,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _chavePixController,
                  maxLength: 32,
                  decoration: InputDecoration(
                    labelText: 'Valor da chave PIX:',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(FontAwesomeIcons.qrcode),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Limpar campo',
                      onPressed: () {
                        _chavePixController.clear();
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O valor da chave é obrigatório';
                    }
                    if (ignorarTipoChavePix) {
                      return null;
                    }
                    if (Validador.validarChavePixSelecionada(
                            value, tipoChavePix) ==
                        false) {
                      return 'Chave PIX inválida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  keyboardType: TextInputType.multiline,
                  controller: _descricaoController,
                  maxLength: 200,
                  decoration: InputDecoration(
                    labelText: 'Descrição:',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(FontAwesomeIcons.circleInfo),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Descrição é obrigatória';
                    }
                    return null;
                  },
                  minLines: 3,
                  maxLines: 5,
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _quantidadeMinimaEncomendaController,
                  maxLength: 2,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Quantidade mínima de itens para encomenda:',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(FontAwesomeIcons.cartPlus),
                    helperText: 'Ex: 2, 3, 4...',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'A quantidade mínima de itens é obrigatória';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _locaisEntregaController,
                  decoration: InputDecoration(
                    labelText: 'Possíveis locais de entrega:',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(FontAwesomeIcons.mapLocationDot),
                    helperText:
                        'Ex: PAF II, Instituto de Biologia, Faculdade de Educação',
                    helperMaxLines: 2,
                    suffixIcon: IconButton(
                      icon: const Icon(FontAwesomeIcons.plus),
                      tooltip: 'Adicionar local de entrega',
                      onPressed: () {
                        verificarLocalEntrega();
                      },
                    ),
                  ),
                  inputFormatters: [
                    FormatadorLetrasMaiusculas(),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      mostrarMapa = !mostrarMapa;
                    });
                  },
                  icon: const Icon(FontAwesomeIcons.mapPin),
                  label: Text(
                      mostrarMapa ? 'Fechar mapa' : 'Selecionar local no mapa'),
                ),
                const SizedBox(height: 5),
                mostrarMapaLocalEntrega(),
                const SizedBox(height: 10),
                const SizedBox(
                  height: 30,
                  child: Text('Locais de entrega selecionados:',
                      style: TextStyle(fontSize: 15)),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (var local in _locaisEntrega)
                      Chip(
                        label: Text(local.nome),
                        avatar: const Icon(FontAwesomeIcons.locationArrow),
                        deleteButtonTooltipMessage: 'Remover local de entrega',
                        onDeleted: () {
                          setState(() {
                            _locaisEntrega.remove(local);
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_locaisEntrega.isEmpty) {
                        WidgetUtils.showSnackbar(
                            mensagem:
                                'Selecione pelo menos um local de entrega',
                            context: context,
                            erro: true);
                        return;
                      }

                      editarEmpresa();
                    }
                  },
                  child: Text(empresa.id == null ? 'Cadastrar' : 'Atualizar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget mostrarMapaLocalEntrega() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 400),
      crossFadeState:
          mostrarMapa ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      firstChild: Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Stack(
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: coordenadaInicial,
                    initialZoom: _zoom,
                    onTap: (_, latlng) => setState(() => coordenadas = latlng),
                  ),
                  children: [
                    TileLayer(
                      tileProvider: CancellableNetworkTileProvider(),
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    if (coordenadas != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: coordenadas!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_pin,
                                color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'zoom_in',
                      onPressed: () {
                        setState(() => _zoom++);
                        _mapController.move(
                            _mapController.camera.center, _zoom);
                      },
                      child: const Icon(Icons.zoom_in),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'zoom_out',
                      onPressed: () {
                        setState(() => _zoom--);
                        _mapController.move(
                            _mapController.camera.center, _zoom);
                      },
                      child: const Icon(Icons.zoom_out),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton.small(
                      heroTag: 'recenter',
                      onPressed: () {
                        _mapController.move(coordenadaInicial, _zoom);
                      },
                      child: const Icon(Icons.my_location),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      secondChild: const SizedBox.shrink(),
    );
  }
}
