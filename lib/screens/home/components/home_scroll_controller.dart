import 'package:flutter/material.dart';
import 'package:orsocook/utils/logger.dart';

class HomeScrollController {
  final ScrollController scrollController = ScrollController();
  final GlobalKey categoriesKey = GlobalKey();
  final GlobalKey carouselKey = GlobalKey(); // Nuovo key per il carousel
  bool _hasJumped = false;

  void init() {
    AppLogger.debug('🔍 [SCROLL] init chiamato');
  }

  bool onScrollNotification(ScrollNotification notification) {
    if (_hasJumped) return false;

    if (notification is ScrollUpdateNotification) {
      final scrollPosition = notification.metrics.pixels;
      AppLogger.debug(
          '🔍 [SCROLL] Posizione scroll: $scrollPosition, hasJumped: $_hasJumped');

      if (scrollPosition > 5) {
        AppLogger.debug('🔍 [SCROLL] Trigger attivato! Scroll position > 5');
        _hasJumped = true;
        _scrollToCategories();
        return true;
      }
    }
    return false;
  }

  void _scrollToCategories() {
    AppLogger.debug('🔍 [SCROLL] _scrollToCategories chiamato');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Calcola l'altezza del carousel
      final carouselContext = carouselKey.currentContext;
      if (carouselContext != null) {
        final carouselBox = carouselContext.findRenderObject() as RenderBox?;
        if (carouselBox != null) {
          final carouselHeight = carouselBox.size.height;
          AppLogger.debug('🔍 [SCROLL] Altezza carousel: $carouselHeight');

          // Scrolla esattamente dell'altezza del carousel
          scrollController
              .animateTo(
            carouselHeight,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
          )
              .then((_) {
            AppLogger.debug('🔍 [SCROLL] Scroll completato!');
          }).catchError((e) {
            AppLogger.error('🔍 [SCROLL] Errore durante lo scroll: $e');
          });
        } else {
          AppLogger.debug('🔍 [SCROLL] carouselBox è NULL');
        }
      } else {
        AppLogger.debug('🔍 [SCROLL] carouselContext è NULL');
      }
    });
  }

  void scrollToCategoriesManually() {
    AppLogger.debug('🔍 [SCROLL] scrollToCategoriesManually chiamato');
    _scrollToCategories();
  }

  void reset() {
    _hasJumped = false;
    AppLogger.debug('🔍 [SCROLL] reset chiamato, hasJumped = false');
  }

  void dispose() {
    scrollController.dispose();
    AppLogger.debug('🔍 [SCROLL] HomeScrollController distrutto');
  }
}
