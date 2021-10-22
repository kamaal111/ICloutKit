package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
)

func main() {
	SCHEME := os.Getenv("SCHEME")
	XCODE_PATH := os.Getenv("XCODE_PATH")
	DESTINATION := os.Getenv("DESTINATION")

	if XCODE_PATH == "" {
		XCODE_PATH = "/Applications/Xcode.app"
		log.Printf("no xcode path provided using %s", XCODE_PATH)
	}
	if SCHEME == "" {
		log.Fatalln("No scheme provided")
	}
	if DESTINATION == "" {
		DESTINATION = "platform=iOS Simulator,name=iPhone 13"
		log.Printf("no destination provided using %s", DESTINATION)
	}

	xcodebuild := fmt.Sprintf("%s/Contents/Developer/usr/bin/xcodebuild", XCODE_PATH)
	buildDocumentationCommand := exec.Command(xcodebuild, "docbuild", "-scheme", SCHEME, "-derivedDataPath", "DerivedData", "-destination", DESTINATION)
	log.Printf("running %s\n", buildDocumentationCommand)
	_, err := buildDocumentationCommand.Output()
	if err != nil {
		log.Fatalln(err)
	}

	doccArchivePath := fmt.Sprintf("DerivedData/Build/Products/Debug-iphonesimulator/%s.doccarchive", SCHEME)
	_, err = os.Stat(doccArchivePath)
	if os.IsNotExist(err) {
		log.Fatalln(err)
	}

	err = copy(doccArchivePath, fmt.Sprintf("%s.doccarchive", SCHEME))
	if os.IsNotExist(err) {
		log.Fatalln(err)
	}

	log.Println("done creating documentation")
}

func copy(fromPath string, destination string) error {
	return os.Rename(fromPath, destination)
}
