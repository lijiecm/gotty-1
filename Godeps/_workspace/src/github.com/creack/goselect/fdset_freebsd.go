// +build freebsd

package goselect

import "syscall"

// FDSet wraps syscall.FdSet with convenience methods
type FDSet syscall.FdSet

// Set adds the fd to the set
func (fds *FDSet) Set(fd uintptr) {
	fds.X__fds_bits[fd/NFDBITS] |= (1 << (fd % NFDBITS))
}

// Clear remove the fd from the set
func (fds *FDSet) Clear(fd uintptr) {
	fds.X__fds_bits[fd/NFDBITS] &^= (1 << (fd % NFDBITS))
}

// IsSet check if the given fd is set
func (fds *FDSet) IsSet(fd uintptr) bool {
	return fds.X__fds_bits[fd/NFDBITS]&(1<<(fd%NFDBITS)) != 0
}

// Keep a null set to avoid reinstatiation
var nullFdSet = &FDSet{}

// Zero empties the Set
func (fds *FDSet) Zero() {
	copy(fds.X__fds_bits[:], (nullFdSet).X__fds_bits[:])
}
