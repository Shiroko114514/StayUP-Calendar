package com.stayup.schedule

import android.database.Cursor
import android.database.MatrixCursor
import android.os.CancellationSignal
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract.Document
import android.provider.DocumentsContract.Root
import android.provider.DocumentsProvider
import android.webkit.MimeTypeMap
import java.io.File
import java.io.FileNotFoundException

/**
 * DocumentsProvider implementation for exposing app's private data directories
 * in the system file manager sidebar.
 */
class AppDocumentsProvider : DocumentsProvider() {

    companion object {
        private val DEFAULT_ROOT_PROJECTION = arrayOf(
            Root.COLUMN_ROOT_ID,
            Root.COLUMN_MIME_TYPES,
            Root.COLUMN_FLAGS,
            Root.COLUMN_ICON,
            Root.COLUMN_TITLE,
            Root.COLUMN_SUMMARY,
            Root.COLUMN_DOCUMENT_ID,
            Root.COLUMN_AVAILABLE_BYTES
        )

        private val DEFAULT_DOCUMENT_PROJECTION = arrayOf(
            Document.COLUMN_DOCUMENT_ID,
            Document.COLUMN_MIME_TYPE,
            Document.COLUMN_DISPLAY_NAME,
            Document.COLUMN_LAST_MODIFIED,
            Document.COLUMN_FLAGS,
            Document.COLUMN_SIZE
        )
    }

    override fun onCreate(): Boolean = true

    override fun queryRoots(projection: Array<out String>?): Cursor {
        val result = MatrixCursor(projection ?: DEFAULT_ROOT_PROJECTION)
        val context = context ?: return result

        // Add app's files directory as root
        result.newRow().apply {
            add(Root.COLUMN_ROOT_ID, "app_data")
            add(Root.COLUMN_TITLE, "StayUP课程表")
            add(Root.COLUMN_SUMMARY, null)
            add(Root.COLUMN_DOCUMENT_ID, getDocIdForFile(context.filesDir))
            add(Root.COLUMN_ICON, context.applicationInfo.icon)
            add(Root.COLUMN_FLAGS, Root.FLAG_SUPPORTS_CREATE or Root.FLAG_SUPPORTS_IS_CHILD)
            add(Root.COLUMN_MIME_TYPES, "*/*")
            add(Root.COLUMN_AVAILABLE_BYTES, context.filesDir.freeSpace)
        }

        result.newRow().apply {
            add(Root.COLUMN_ROOT_ID, "data_data")
            add(Root.COLUMN_TITLE, "StayUP课程表")
            add(Root.COLUMN_SUMMARY, null)
            add(Root.COLUMN_DOCUMENT_ID, getDocIdForFile(context.filesDir))
            add(Root.COLUMN_ICON, context.applicationInfo.icon)
            add(Root.COLUMN_FLAGS, Root.FLAG_SUPPORTS_CREATE or Root.FLAG_SUPPORTS_IS_CHILD)
            add(Root.COLUMN_MIME_TYPES, "*/*")
            add(Root.COLUMN_AVAILABLE_BYTES, context.filesDir.freeSpace)
        }

        return result
    }

    override fun queryDocument(documentId: String?, projection: Array<out String>?): Cursor {
        val result = MatrixCursor(projection ?: DEFAULT_DOCUMENT_PROJECTION)
        val file = getFileForDocId(documentId ?: return result)
        includeFile(result, file)
        return result
    }

    override fun queryChildDocuments(
        parentDocumentId: String?,
        projection: Array<out String>?,
        sortOrder: String?
    ): Cursor {
        val result = MatrixCursor(projection ?: DEFAULT_DOCUMENT_PROJECTION)
        val parent = getFileForDocId(parentDocumentId ?: return result)
        
        parent.listFiles()?.forEach { file ->
            includeFile(result, file)
        }
        
        return result
    }

    override fun openDocument(
        documentId: String?,
        mode: String?,
        signal: CancellationSignal?
    ): ParcelFileDescriptor {
        val file = getFileForDocId(documentId ?: throw FileNotFoundException("No document ID"))
        val accessMode = ParcelFileDescriptor.parseMode(mode)
        return ParcelFileDescriptor.open(file, accessMode)
    }

    private fun getDocIdForFile(file: File): String {
        return file.absolutePath
    }

    private fun getFileForDocId(docId: String): File {
        val file = File(docId)
        val context = context ?: throw FileNotFoundException("Context is null")
        
        // Security check: only allow access to app's own directories
        val baseDir = context.filesDir.parentFile ?: throw FileNotFoundException("Invalid base dir")
        if (!file.canonicalPath.startsWith(baseDir.canonicalPath)) {
            throw SecurityException("Access denied to path outside app directory")
        }
        
        if (!file.exists()) {
            throw FileNotFoundException("File does not exist: ${file.absolutePath}")
        }
        
        return file
    }

    private fun includeFile(result: MatrixCursor, file: File) {
        val mimeType = if (file.isDirectory) {
            Document.MIME_TYPE_DIR
        } else {
            getMimeType(file)
        }

        var flags = 0
        if (file.isDirectory && file.canWrite()) {
            flags = flags or Document.FLAG_DIR_SUPPORTS_CREATE
        }
        if (file.canWrite()) {
            flags = flags or Document.FLAG_SUPPORTS_WRITE
            flags = flags or Document.FLAG_SUPPORTS_DELETE
        }

        result.newRow().apply {
            add(Document.COLUMN_DOCUMENT_ID, getDocIdForFile(file))
            add(Document.COLUMN_DISPLAY_NAME, file.name)
            add(Document.COLUMN_SIZE, file.length())
            add(Document.COLUMN_MIME_TYPE, mimeType)
            add(Document.COLUMN_LAST_MODIFIED, file.lastModified())
            add(Document.COLUMN_FLAGS, flags)
        }
    }

    private fun getMimeType(file: File): String {
        val extension = file.extension
        return if (extension.isNotEmpty()) {
            MimeTypeMap.getSingleton().getMimeTypeFromExtension(extension.lowercase())
                ?: "application/octet-stream"
        } else {
            "application/octet-stream"
        }
    }

    override fun createDocument(
        parentDocumentId: String?,
        mimeType: String?,
        displayName: String?
    ): String {
        val parent = getFileForDocId(parentDocumentId ?: throw FileNotFoundException("No parent"))
        val file = File(parent, displayName ?: "新文件")
        
        if (mimeType == Document.MIME_TYPE_DIR) {
            file.mkdir()
        } else {
            file.createNewFile()
        }
        
        return getDocIdForFile(file)
    }

    override fun deleteDocument(documentId: String?) {
        val file = getFileForDocId(documentId ?: throw FileNotFoundException("No document ID"))
        if (!file.delete()) {
            throw FileNotFoundException("Failed to delete: ${file.absolutePath}")
        }
    }
}
