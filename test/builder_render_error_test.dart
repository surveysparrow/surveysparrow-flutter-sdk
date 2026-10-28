import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surveysparrow_flutter_sdk/src/builder/builder.dart';

void main() {
  testWidgets('a bad schema node is skipped and reported once as APP_CRASH', (tester) async {
    final reports = <String>[];
    SpotcheckActions.renderErrorReporter = (error, stack, nodeKey) => reports.add(nodeKey);

    // `slot` must be a String; an int makes the node throw while rendering.
    const badSchema = [
      {'slot': 123},
      {'slot': 'ok'},
    ];
    const context = BuilderContext(slots: {'ok': Text('still here')});

    await tester.pumpWidget(const MaterialApp(home: SchemaBuilder(schema: badSchema, context: context)));
    // Rebuilds hit the same failure; it must not be reported again.
    await tester.pumpWidget(const MaterialApp(home: Center(child: SchemaBuilder(schema: badSchema, context: context))));

    expect(tester.takeException(), isNull);
    expect(find.text('still here'), findsOneWidget);
    expect(reports, ['root-0']);

    SpotcheckActions.renderErrorReporter = null;
  });
}
