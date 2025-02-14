import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';
import 'package:coffee_mapper_web/models/farmer_form_data.dart';

class ArchiveUtils {
  static final _log = Logger('ArchiveUtils');

  static Future<void> archiveDocument(String documentId) async {
    final firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('No user logged in');

    // Get the original document and all its subcollections
    final sourceDoc = firestore.collection('savedRegions').doc(documentId);
    final sourceData = await sourceDoc.get();
    if (!sourceData.exists) throw Exception('Document not found');

    // Create a batch for atomic operations
    final batch = firestore.batch();
    final timestamp = Timestamp.fromDate(DateTime.now());

    // 1. Update original document as archived (existing logic)
    final updates = {
      'regionCategory': 'Archived',
      'savedBy': currentUser.email,
      'updatedOn': timestamp,
      'latestDataForDashboard.regionCategory': 'Archived',
      'latestDataForDashboard.updatedOn': timestamp,
      'latestDataForDashboard.savedBy': currentUser.email,
    };

    batch.update(sourceDoc, updates);
    batch.update(
        sourceDoc.collection('regionInsights').doc('latestInformation'), {
      'regionCategory': 'Archived',
      'updatedOn': timestamp,
      'savedBy': currentUser.email,
    });

    // 2. Copy to archivedRegions with updates
    final targetDoc = firestore.collection('archivedRegions').doc(documentId);
    batch.set(targetDoc, {...sourceData.data()!, ...updates});

    await batch.commit();

    // 3. Copy all subcollections
    await _copySubcollections(sourceDoc, targetDoc);

    // 4. Delete original document and its subcollections
    await _deleteDocumentWithSubcollections(sourceDoc);
  }

  static Future<void> _copySubcollections(
      DocumentReference source, DocumentReference target) async {
    final collections = await source.collection('regionInsights').get();
    final docs = collections.docs;

    for (final doc in docs) {
      final targetSubDoc = target.collection('regionInsights').doc(doc.id);
      await targetSubDoc.set(doc.data());
    }
  }

  static Future<void> _deleteDocumentWithSubcollections(
      DocumentReference document) async {
    final collections = await document.collection('regionInsights').get();
    final docs = collections.docs;

    for (final doc in docs) {
      await doc.reference.delete();
    }

    await document.delete();
  }

  // Test method to migrate existing archived documents
  static Future<void> testMigrateExistingArchivedDocuments() async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Find all documents marked as Archived
      final query = firestore
          .collection('savedRegions')
          .where('regionCategory', isEqualTo: 'Archived');

      final snapshot = await query.get();
      _log.info('Found ${snapshot.docs.length} archived documents to migrate');

      int successCount = 0;
      int failureCount = 0;

      for (final doc in snapshot.docs) {
        try {
          _log.info('Migrating document ${doc.id}...');
          await archiveDocument(doc.id);
          successCount++;
          _log.info('Successfully migrated ${doc.id}');
        } catch (e) {
          failureCount++;
          _log.severe('Failed to migrate ${doc.id}: $e');
        }
      }

      _log.info(
          'Migration complete. Success: $successCount, Failed: $failureCount');
    } catch (e) {
      _log.severe('Migration failed: $e');
      rethrow;
    }
  }

  // Archive a beneficiary document
  static Future<void> archiveBeneficiary(FarmerFormData data) async {
    if (data.id == null) throw Exception('Document ID is required');

    final firestore = FirebaseFirestore.instance;
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null || currentUser.email == null) {
      throw Exception('No authenticated user found');
    }

    try {
      // Update document with archive metadata
      await firestore.collection('farmerApplications').doc(data.id).update({
        'status': 'archived',
        'archivedOn': Timestamp.now(),
        'archivedBy': currentUser.email,
      });

      _log.info('Successfully archived beneficiary ${data.id}');
    } catch (e) {
      _log.severe('Error archiving beneficiary ${data.id}: $e');
      rethrow;
    }
  }
}
