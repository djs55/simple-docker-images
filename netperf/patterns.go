package main

import (
	"io/ioutil"
	"log"
	"os"
	"path"
)

var patterns = map[string][]byte{
	"deadbeef": {0xde, 0xad, 0xbe, 0xef},
}

func main() {
	if err := os.Mkdir("patterns", 0755); err != nil {
		log.Fatal(err)
	}
	for file, contents := range patterns {
		path := path.Join("patterns", file)
		if err := ioutil.WriteFile(path, contents, 0644); err != nil {
			log.Fatal(err)
		}
	}
}
