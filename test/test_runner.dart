import "package:unittest/unittest.dart";
import "bloom_filter_test.dart" as bloom;
import "int_set_test.dart" as intSet;
import "sparse_vector_test.dart" as sparseVec;
import "simhash_test.dart" as simHash;
import "mphf_test.dart" as mphf;
import "trie_test.dart" as trie;
import "count_set_test.dart" as countSet;

main() {
  bloom.main();
  intSet.main();
  sparseVec.main();
  simHash.main();
  mphf.main();
  trie.main();
  countSet.main();
}