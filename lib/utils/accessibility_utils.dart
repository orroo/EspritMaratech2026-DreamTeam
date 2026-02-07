import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';

class AccessibilityUtils {
  // Store RenderObjects associated with IDs for the current screen
  static final Map<String, RenderObject> _renderObjects = {};

  static String getScreenLayout(BuildContext context) {
    try {
      final route = ModalRoute.of(context);
      if (route == null) return "Aucun écran détecté.";

      // Reset for new analysis
      _renderObjects.clear();
      final idCounts = <String, int>{};

      final buffer = StringBuffer();
      final addedTexts = <String>{};

      void visitElement(Element element, {String? inheritedLabel}) {
        String? text;
        bool isInteractive = false;

        // Check for interactive elements
        if (element.widget is ButtonStyleButton ||
            element.widget is InkWell ||
            element.widget is IconButton ||
            element.widget is FloatingActionButton ||
            element.widget is PopupMenuButton ||
            element.widget is GestureDetector) {
          isInteractive = true;
        }

        // Extract text
        if (element.widget is Text) {
          final textWidget = element.widget as Text;
          text = textWidget.data;
          if (text == null && textWidget.textSpan != null) {
            text = textWidget.textSpan!.toPlainText();
          }
        } else if (element.widget is RichText) {
          final richText = element.widget as RichText;
          text = richText.text.toPlainText();
        } else if (element.widget is Semantics) {
          final semantics = element.widget as Semantics;
          if (semantics.properties.label != null) {
            // Treat Semantics label as "inherited" for children
            inheritedLabel = semantics.properties.label;
            // Also use it here if this Semantics itself is effectively the node we care about
            // But usually Semantics wraps something.
            // We'll let the label propagate down.
            // However, if Semantics HAS interaction (onTap), it might be the target.
            if (semantics.properties.onTap != null) {
              text = semantics.properties.label;
              isInteractive = true;
            }
          }
          if (semantics.properties.value != null) {
            // Values often accompany labels or stand alone
            final val = semantics.properties.value;
            text = text == null ? val : "$text $val";
          }
          if (semantics.properties.hint != null) {
            final hint = semantics.properties.hint;
            text = text == null ? hint : "$text $hint";
          }
        } else if (element.widget is TextField) {
          final tf = element.widget as TextField;
          final label = tf.decoration?.labelText;
          final hint = tf.decoration?.hintText;
          text = "Champ de texte: ${label ?? hint ?? 'Sans label'}";
          isInteractive = true;
        } else if (element.widget is IconButton) {
          final iconBtn = element.widget as IconButton;
          if (iconBtn.tooltip != null) {
            text = iconBtn.tooltip;
            isInteractive = true;
          }
        } else if (element.widget is FloatingActionButton) {
          final fab = element.widget as FloatingActionButton;
          if (fab.tooltip != null) {
            text = fab.tooltip;
            isInteractive = true;
          }
        }

        // Use inherited label if no specific text is found for this interactive element
        if (text == null && isInteractive && inheritedLabel != null) {
          text = inheritedLabel;
        }

        // If interactive or has text, log it
        if (text != null && text.trim().isNotEmpty) {
          String logEntry = text.trim();

          if (isInteractive) {
            final renderObject = element.renderObject;
            if (renderObject != null) {
              final id = _generateId(logEntry, idCounts);
              _renderObjects[id] = renderObject;
              logEntry = "[$id] $logEntry (Interactif)";
            }
          }

          if (addedTexts.add(logEntry)) {
            buffer.writeln("- $logEntry");
          }
        } else if (isInteractive) {
          // Interactive but no text (e.g. Icon button without tooltip?)
          final renderObject = element.renderObject;
          if (renderObject != null) {
            final id = _generateId("element_interactif", idCounts);
            _renderObjects[id] = renderObject;
            buffer.writeln("- [$id] Élément interactif (Bouton/Image)");
          }
        }

        element.visitChildren(
            (child) => visitElement(child, inheritedLabel: inheritedLabel));
      }

      if (route.subtreeContext != null) {
        (route.subtreeContext as Element).visitChildren(visitElement);
      } else {
        return "Impossible d'analyser l'écran.";
      }

      final result = buffer.toString();
      return result.isEmpty ? "L'écran semble vide." : result;
    } catch (e) {
      return "Erreur lors de l'analyse: $e";
    }
  }

  static String _generateId(String text, Map<String, int> counts) {
    // Slugify text: lowercase, remove accents, replace spaces/special chars with _
    String base = text.toLowerCase().trim();
    base = base.replaceAll(RegExp(r'[àáâãäå]'), 'a');
    base = base.replaceAll(RegExp(r'[ç]'), 'c');
    base = base.replaceAll(RegExp(r'[èéêë]'), 'e');
    base = base.replaceAll(RegExp(r'[ìíîï]'), 'i');
    base = base.replaceAll(RegExp(r'[òóôõö]'), 'o');
    base = base.replaceAll(RegExp(r'[ùúûü]'), 'u');
    base = base.replaceAll(RegExp(r'[ýÿ]'), 'y');
    base = base.replaceAll(RegExp(r'[^a-z0-9]+'), '_');

    // Trim underscores from start/end
    base = base.replaceAll(RegExp(r'^_+|_+$'), '');

    if (base.isEmpty) base = "element";

    // Handle duplicates
    int count = counts[base] ?? 0;
    counts[base] = count + 1;

    return count == 0 ? base : "${base}_${count + 1}";
  }

  static Future<void> simulateTap(String id) async {
    final renderObject = _renderObjects[id];
    if (renderObject == null || !renderObject.attached) {
      print("Element [$id] not found or detached.");
      return;
    }

    if (renderObject is RenderBox) {
      final center =
          renderObject.localToGlobal(renderObject.size.center(Offset.zero));

      final hitTestResult = HitTestResult();
      WidgetsBinding.instance.hitTest(hitTestResult, center);

      final pointerDownEvent = PointerDownEvent(
        position: center,
        kind: PointerDeviceKind.touch,
      );

      GestureBinding.instance.handlePointerEvent(pointerDownEvent);

      await Future.delayed(const Duration(milliseconds: 100));

      final pointerUpEvent = PointerUpEvent(
        position: center,
        kind: PointerDeviceKind.touch,
      );

      GestureBinding.instance.handlePointerEvent(pointerUpEvent);
      print("Simulated tap on element [$id] at $center");
    }
  }
}
