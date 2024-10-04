namespace Chromely.NativeHosts.WinHost;

public static partial class Interop
{
    public static partial class FileDialog
    {
        
    }


      [ComImport]
    [Guid("DC1C5A9C-E88A-4DDE-A5A1-60F82A20AEF7")]
    [ClassInterface(ClassInterfaceType.None)]
    public class FileOpenDialog
    {
    }

    [ComImport]
    [Guid("42f85136-db7e-439c-85f1-e4075d135fc8")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IFileOpenDialog
    {
        [PreserveSig] int Show([In] IntPtr hwndParent);
        void SetFileTypes(); // Not fully defined
        void SetFileTypeIndex(); // Not fully defined
        void GetFileTypeIndex(); // Not fully defined
        void Advise(); // Not fully defined
        void Unadvise();
        void SetOptions([In] FOS fos);
        void GetOptions(out FOS pfos);
        void SetDefaultFolder(); // Not fully defined
        void SetFolder(); // Not fully defined
        void GetFolder(); // Not fully defined
        void GetCurrentSelection(); // Not fully defined
        void SetFileName(); // Not fully defined
        void GetFileName(); // Not fully defined
        void SetTitle([In, MarshalAs(UnmanagedType.LPWStr)] string pszTitle);
        void SetOkButtonLabel(); // Not fully defined
        void SetFileNameLabel(); // Not fully defined
        void GetResult(out IShellItem ppsi);
        void AddPlace(); // Not fully defined
        void SetDefaultExtension(); // Not fully defined
        void Close(); // Not fully defined
        void SetClientGuid(); // Not fully defined
        void ClearClientData();
        void SetFilter(); // Not fully defined
        void GetResults(); // Not fully defined
        void GetSelectedItems(); // Not fully defined
    }

    [ComImport]
    [Guid("43826d1e-e718-42ee-bc55-a1e261c37bfe")]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    public interface IShellItem
    {
        void BindToHandler(); // Not fully defined
        void GetParent(); // Not fully defined
        void GetDisplayName([In] SIGDN sigdnName, out IntPtr ppszName);
        void GetAttributes(); // Not fully defined
        void Compare(); // Not fully defined
    }

    public enum SIGDN : uint
    {
        SIGDN_FILESYSPATH = 0x80058000,
    }

    [Flags]
    public enum FOS : uint
    {
        FOS_PICKFOLDERS = 0x00000020,
        FOS_FORCEFILESYSTEM = 0x00000040, // Ensure that the item returned is a file system item.
    }

}