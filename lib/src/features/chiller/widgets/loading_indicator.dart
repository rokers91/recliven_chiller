import 'package:flutter/material.dart';
import 'package:recliven_chiller/barrel/core.dart';

//constructor de los loadingprogressindicator, este esta pesonalizado para que trabaje con las
//diferentes pantallas mediante el uso de keys
class LoadingIndicator extends StatefulWidget {
  final Color color;
  final double strokeWidth;
  final String loadingKey;
  final bool isLoading;

  const LoadingIndicator({
    super.key,
    this.color = Colors.orange,
    this.strokeWidth = 4.0,
    required this.loadingKey,
    required this.isLoading,
  });

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator> {
  String loadingText = '';

  @override
  Widget build(BuildContext context) {
    switch (widget.loadingKey) {
      case 'startingConnection':
        loadingText = 'Conectando...';
        break;
      case 'settings':
        loadingText = 'Actualizando...';
        break;
      case 'loadingData':
        loadingText = 'Cargando datos de la tabla...';
        break;
      case 'cleaning':
        loadingText = 'Limpiando...';
        break;
      default:
        loadingText = 'Cargando datos...';
    }
    return Center(
      child: Align(
        alignment: Alignment.center,
        child: widget.isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    key: Key(widget.loadingKey),
                    color: widget.color,
                    strokeWidth: widget.strokeWidth,
                  ),
                  SizedBox(height: SizeConstants.paddingMedium),
                  Text(
                    loadingText,
                    style: TextStyle(
                        fontSize: SizeConstants.textSizeMedium,
                        color: AppColors.primaryColorOrange400),
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
