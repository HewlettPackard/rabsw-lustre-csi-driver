/*
 * Copyright 2021, 2022 Hewlett Packard Enterprise Development LP
 * Other additional copyright holders may be indicated within.
 *
 * The entirety of this work is licensed under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 *
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package mock

import (
	"github.com/rexray/gocsi"

	"github.com/HewlettPackard/lustre-csi-driver/pkg/driver"
	"github.com/HewlettPackard/lustre-csi-driver/pkg/mock-driver/provider"
	"github.com/HewlettPackard/lustre-csi-driver/pkg/mock-driver/service"
)

func NewMockDriver() driver.DriverApi {
	return &MockDriver{}
}

type MockDriver struct{}

func (MockDriver) Name() string                                 { return service.Name }
func (MockDriver) Provider() func() gocsi.StoragePluginProvider { return provider.New }
