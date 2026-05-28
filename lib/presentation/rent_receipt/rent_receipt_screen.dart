import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:konnectrent/core/theme/app_theme.dart';
import 'package:konnectrent/core/utils/format_utils.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class RentReceiptScreen extends StatefulWidget {
  const RentReceiptScreen({super.key});

  @override
  State<RentReceiptScreen> createState() => _RentReceiptScreenState();
}

class _RentReceiptScreenState extends State<RentReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenantCtrl = TextEditingController();
  final _landlordCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _rentCtrl = TextEditingController();
  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  bool _generating = false;

  @override
  void dispose() {
    _tenantCtrl.dispose();
    _landlordCtrl.dispose();
    _addressCtrl.dispose();
    _rentCtrl.dispose();
    super.dispose();
  }

  String get _monthLabel =>
      DateFormat('MMMM yyyy').format(_selectedMonth);

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      helpText: 'Select month',
      initialEntryMode: DatePickerEntryMode.calendarOnly,
    );
    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month));
    }
  }

  Future<void> _generate() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _generating = true);
    try {
      final rent = double.tryParse(_rentCtrl.text) ?? 0;
      final bytes = await compute(
        _buildReceiptPdf,
        _ReceiptData(
          tenantName: _tenantCtrl.text.trim(),
          landlordName: _landlordCtrl.text.trim(),
          address: _addressCtrl.text.trim(),
          rentAmount: rent,
          month: _selectedMonth,
        ),
      );
      if (!mounted) return;
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'rent_receipt_${DateFormat('MMM_yyyy').format(_selectedMonth)}.pdf',
      );
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rent Receipt Generator')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceMD),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Receipt Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppTheme.spaceMD),
                    _Field(
                      controller: _tenantCtrl,
                      label: 'Tenant Name',
                      hint: 'Your full name',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    _Field(
                      controller: _landlordCtrl,
                      label: 'Landlord Name',
                      hint: "Landlord's full name",
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    _Field(
                      controller: _addressCtrl,
                      label: 'Property Address',
                      hint: 'Full address of rented property',
                      maxLines: 3,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    _Field(
                      controller: _rentCtrl,
                      label: 'Monthly Rent (₹)',
                      hint: 'e.g. 20000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if ((double.tryParse(v) ?? 0) <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Receipt Month'),
                      subtitle: Text(
                        _monthLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryTeal,
                        ),
                      ),
                      trailing: const Icon(Icons.calendar_month_outlined),
                      onTap: _pickMonth,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceMD),
            // Preview card
            if (_tenantCtrl.text.isNotEmpty &&
                _landlordCtrl.text.isNotEmpty &&
                _rentCtrl.text.isNotEmpty)
              _ReceiptPreview(
                tenant: _tenantCtrl.text,
                landlord: _landlordCtrl.text,
                address: _addressCtrl.text,
                rent: double.tryParse(_rentCtrl.text) ?? 0,
                month: _monthLabel,
              ),
            const SizedBox(height: AppTheme.spaceMD),
            _generating
                ? const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: AppTheme.spaceSM),
                        Text('Generating receipt…'),
                      ],
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _generate,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: const Text('Generate & Share Receipt'),
                  ),
            const SizedBox(height: AppTheme.spaceSM),
            Text(
              'Useful for HRA tax exemption claims under Section 10(13A).',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable form field ──────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMD),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: validator,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onChanged: (_) => (context as Element).markNeedsBuild(),
      ),
    );
  }
}

// ── Receipt preview ──────────────────────────────────────────────────────────

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({
    required this.tenant,
    required this.landlord,
    required this.address,
    required this.rent,
    required this.month,
  });

  final String tenant;
  final String landlord;
  final String address;
  final double rent;
  final String month;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primaryTeal.withAlpha(15),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'RENT RECEIPT',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
              ),
            ),
            const Divider(),
            _Row('Month', month),
            _Row('Received from', tenant),
            _Row('Amount', FormatUtils.toIndianCurrencyFull(rent)),
            _Row('Property', address),
            _Row('Landlord', landlord),
            const SizedBox(height: AppTheme.spaceMD),
            const Text(
              'Signature: ___________________',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryTeal,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

// ── PDF generation (runs in compute isolate) ─────────────────────────────────

class _ReceiptData {
  const _ReceiptData({
    required this.tenantName,
    required this.landlordName,
    required this.address,
    required this.rentAmount,
    required this.month,
  });

  final String tenantName;
  final String landlordName;
  final String address;
  final double rentAmount;
  final DateTime month;
}

Future<Uint8List> _buildReceiptPdf(_ReceiptData data) async {
  final doc = pw.Document();
  final monthLabel = DateFormat('MMMM yyyy').format(data.month);
  final generated = DateFormat('dd MMM yyyy').format(DateTime.now());
  final amountStr =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0)
          .format(data.rentAmount);

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text(
              'RENT RECEIPT',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal700,
                letterSpacing: 3,
              ),
            ),
          ),
          pw.Divider(color: PdfColors.teal700, thickness: 1.5),
          pw.SizedBox(height: 16),
          _pdfRow('Receipt for', monthLabel),
          _pdfRow('Received from', data.tenantName),
          _pdfRow('Amount paid', amountStr),
          _pdfRow('Towards rent of', data.address),
          _pdfRow('Paid to (Landlord)', data.landlordName),
          _pdfRow('Date of issue', generated),
          pw.SizedBox(height: 40),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Tenant Signature',
                      style: const pw.TextStyle(color: PdfColors.grey600),),
                  pw.SizedBox(height: 20),
                  pw.Text('___________________'),
                  pw.Text(data.tenantName),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Landlord Signature',
                      style: const pw.TextStyle(color: PdfColors.grey600),),
                  pw.SizedBox(height: 20),
                  pw.Text('___________________'),
                  pw.Text(data.landlordName),
                ],
              ),
            ],
          ),
          pw.Spacer(),
          pw.Divider(),
          pw.Text(
            'This receipt is valid for HRA exemption under Section 10(13A) of the Income Tax Act, 1961.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    ),
  );
  return doc.save();
}

pw.Widget _pdfRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 160,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.teal800,
              ),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
