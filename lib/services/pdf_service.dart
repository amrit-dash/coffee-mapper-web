import 'dart:html' as html;

import 'package:pdf/widgets.dart' as pw;

import '../models/farmer_form_data.dart';

class PdfService {
  // Label mappings for Odia translations
  final Map<String, String> _labelMappings = {
    'Personal Details': 'ନିଜ ବିବରଣୀ',
    'Name': 'ନାମ',
    'Care of Name': 'ପିତା/ସ୍ୱାମୀଙ୍କ ନାମ',
    'Mobile Number': 'ମୋବାଇଲ୍ ନମ୍ବର',
    'Aadhar Number': 'ଆଧାର ନମ୍ବର',
    'Address Details': 'ଠିକଣା ବିବରଣୀ',
    'Village': 'ଗ୍ରାମ',
    'Block': 'ବ୍ଲକ',
    'District': 'ଜିଲ୍ଲା',
    'Post': 'ପୋଷ୍ଟ',
    'Police Station': 'ଥାନା',
    'Land Details': 'ଜମି ବିବରଣୀ',
    'Land Size': 'ମୋଟ ଜମିର ପରିମାଣ',
    'Land Category': 'ଜମି କିସମ',
    'Khata Number': 'ଖାତା ନମ୍ବର',
    'Plot Number': 'ପ୍ଲଟ ନମ୍ବର',
    'Mauja': 'ମୌଜା',
    'Bank Details': 'ବାଙ୍କ ପାସବୁକ ବିବରଣୀ',
    'Bank Name': 'ବାଙ୍କ ନାମ',
    'Account Number': 'ବାଙ୍କ ଖାତା ନମ୍ବର',
    'IFSC Code': 'ବାଙ୍କ ଇଫସସ',
    'Bank Branch': 'ବାଙ୍କ ସଖା',
  };

  Future<void> generateBeneficiaryPdf(FarmerFormData data) async {
    final htmlContent = '''
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <style>
            @import url('https://fonts.googleapis.com/css2?family=Noto+Sans+Oriya:wght@400;700&display=swap');
            
            :root {
              --primary-color: #2c3e50;
              --border-color: #e0e0e0;
              --background-color: #f8f9fa;
              --text-color: #333;
              --label-width: 250px;
              --spacing: 20px;
            }
            
            body {
              font-family: 'Noto Sans Oriya', sans-serif;
              line-height: 1.6;
              padding: 40px;
              max-width: 900px;
              margin: 0 auto;
              background-color: white;
              color: var(--text-color);
            }
            
            .header {
              text-align: center;
              margin-bottom: 40px;
              padding: 20px;
              background-color: var(--background-color);
              border-radius: 8px;
              border: 1px solid var(--border-color);
            }
            
            .header h1 {
              color: var(--primary-color);
              margin: 0 0 10px 0;
              font-size: 24px;
              line-height: 1.4;
            }
            
            .header h2 {
              color: var(--primary-color);
              margin: 10px 0;
              font-size: 20px;
            }
            
            .section {
              margin: 30px 0;
              padding: 25px;
              border: 1px solid var(--border-color);
              border-radius: 8px;
              background-color: white;
              box-shadow: 0 2px 4px rgba(0,0,0,0.05);
            }
            
            .section-title {
              font-size: 20px;
              font-weight: bold;
              margin-bottom: 20px;
              color: var(--primary-color);
              padding-bottom: 10px;
              border-bottom: 2px solid var(--border-color);
            }
            
            .row {
              display: flex;
              margin: 15px 0;
              align-items: flex-start;
            }
            
            .label-group {
              width: var(--label-width);
              padding-right: var(--spacing);
            }
            
            .english-label {
              font-weight: bold;
              margin-bottom: 4px;
            }
            
            .odia-label {
              color: #666;
              font-size: 0.95em;
            }
            
            .separator {
              margin: 0 var(--spacing);
              color: #666;
              font-weight: bold;
            }
            
            .value {
              flex: 1;
              padding: 8px 15px;
              background-color: var(--background-color);
              border-radius: 4px;
              min-height: 24px;
            }
            
            .footer {
              margin-top: 50px;
              padding-top: 30px;
              border-top: 1px solid var(--border-color);
            }
            
            .signature-section {
              display: flex;
              justify-content: space-between;
              margin-top: 30px;
              padding: 20px;
              background-color: var(--background-color);
              border-radius: 8px;
            }
            
            .digital-signature {
              text-align: right;
              margin-top: 10px;
            }
            
            .digital-signature-text {
              font-size: 0.8em;
              color: #666;
              font-style: italic;
              margin-bottom: 5px;
            }
            
            @media print {
              body {
                padding: 20px;
              }
              
              .section {
                break-inside: avoid;
                border: 1px solid #ddd;
                box-shadow: none;
              }
              
              .value {
                background-color: #f8f9fa !important;
                -webkit-print-color-adjust: exact;
              }
            }
          </style>
        </head>
        <body>
          <div class="header">
            <h1>Beneficiary Application Form</h1>
            <h2>ନିରନ୍ତର ଜୀବିକା ପାଇଁ କଫି ଚାଷ (CPSL)</h2>
            <h2>କଫି ଚାଷ / ଛାୟା ବୃକ୍ଷ ରୋପଣ ପାଇଁ ଆବେଦନ ପତ୍ର</h2>
          </div>
          
          <div class="section">
            <div class="section-title">Personal Details / ନିଜ ବିବରଣୀ</div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Name</div>
                <div class="odia-label">ନାମ</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.name ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Father's Name</div>
                <div class="odia-label">ପିତାଙ୍କ ନାମ</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.careOfName ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Mobile</div>
                <div class="odia-label">ମୋବାଇଲ</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.mobileNumber ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Aadhar</div>
                <div class="odia-label">ଆଧାର</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.aadharNumber ?? ''}</div>
            </div>
          </div>
          
          <div class="section">
            <div class="section-title">Address Details / ଠିକଣା ବିବରଣୀ</div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Village</div>
                <div class="odia-label">ଗ୍ରାମ</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.village ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Block</div>
                <div class="odia-label">ବ୍ଲକ</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.block ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">District</div>
                <div class="odia-label">ଜିଲ୍ଲା</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.district ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Post</div>
                <div class="odia-label">ପୋଷ୍ଟ</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.post ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Police Station</div>
                <div class="odia-label">ଥାନା</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.policeStation ?? ''}</div>
            </div>
          </div>
          
          <div class="section">
            <div class="section-title">Land Details / ଜମି ବିବରଣୀ</div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Land Size</div>
                <div class="odia-label">ମୋଟ ଜମିର ପରିମାଣ</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.landSize ?? ''} acres</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Land Category</div>
                <div class="odia-label">ଜମି କିସମ</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.landCategory ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Plot Number</div>
                <div class="odia-label">ପ୍ଲଟ ନମ୍ବର</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.plotNumber ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Khata Number</div>
                <div class="odia-label">ଖାତା ନମ୍ବର</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.khataNumber ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Mauja</div>
                <div class="odia-label">ମୌଜା</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.mauja ?? ''}</div>
            </div>
          </div>
          
          <div class="section">
            <div class="section-title">Bank Details / ବ୍ୟାଙ୍କ ବିବରଣୀ</div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Bank Name</div>
                <div class="odia-label">ବ୍ୟାଙ୍କ ନାମ</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.bankName ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Account Number</div>
                <div class="odia-label">ଆକାଉଣ୍ଟ ନମ୍ବର</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.bankAccountNumber ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">IFSC</div>
                <div class="odia-label">ଆଇଏଫଏସସି</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.bankIFSC ?? ''}</div>
            </div>
            <div class="row">
              <div class="label-group">
                <div class="english-label">Branch</div>
                <div class="odia-label">ସଖା</div>
              </div>
              <div class="separator">:</div>
              <div class="value">${data.bankBranch ?? ''}</div>
            </div>
          </div>
          
          <div class="footer">
            <div class="signature-section">
              <div>
                <div class="english-label">Date</div>
                <div class="value">${data.submittedOn?.day ?? ''}-${data.submittedOn?.month ?? ''}-${data.submittedOn?.year ?? ''}</div>
              </div>
              <div class="digital-signature">
                <div class="digital-signature-text">Digitally Verified and Accepted</div>
                <div class="digital-signature-text">ଡିଜିଟାଲ୍ ଭାବରେ ଯାଞ୍ଚ ଏବଂ ସ୍ୱୀକୃତ</div>
                <div class="value">Beneficiary's Signature / ହିତାଧିକାରୀଙ୍କ ସ୍ଵାକ୍ଷର</div>
              </div>
            </div>
          </div>
        </body>
      </html>
    ''';

    // Create a new window with the content
    final blob = html.Blob([htmlContent], 'text/html');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement()
      ..href = url
      ..style.display = 'none'
      ..download = 'beneficiary_${data.name ?? 'form'}.html';

    html.document.body?.append(anchor);
    anchor.click();
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  pw.Widget _buildSection(String title, List<pw.Widget> rows) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        ...rows,
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(': '),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }
}
